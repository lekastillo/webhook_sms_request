require "net/http"
require "json"
require "sidekiq"
require "rack/env"
require "sinatra/activerecord"
require_relative "../models/sms_request"
require_relative "../services/twilio_sms"

Sidekiq.configure_server do |config|
  config.redis = { url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}", password: ENV["REDIS_PASSWORD"] }
end
class SmsRequestWorker
  include Sidekiq::Worker
  sidekiq_options :retry => ENV['RETRY_COUNT'].to_i
  
  def perform(sms_request_id)
    puts "::::::::::::::::::::::::::::::::::::::::::::::::::: Worker doing something \n"

    sms_request=SmsRequest.find(sms_request_id)

    if sms_request 
      uri = URI("#{ENV['SCRAPPER_ENDPOINT']}/#{sms_request.dui}")
      read_timeout = ENV['SCRAPPER_READ_TIMEOUT'].to_i 
      open_timeout = ENV['SCRAPPER_OPEN_TIMEOUT'].to_i

      begin
        Net::HTTP.start(uri.host,uri.port,
                    :use_ssl => uri.scheme == 'https',
                    :read_timeout => read_timeout,
                    :open_timeout => open_timeout) do |http|
          request = Net::HTTP::Get.new uri
          response = http.request request
        end

        if response.code == 200
          response = JSON.parse(response.read_body)

          message = ""
          # Re-escribiendo el mensaje
      	  if response["success"] == true
            message = "Usted es beneficiario de los $300USD"
          else
            message = "Usted no es beneficiario. Llame al 2565-5555 si aplica al criterio de seleccion"
          end
          
          resp=TwilioSms.send_sms(sms_request.phone, message)

          sms_request.update_column(:status, 1)
          sms_request.update_column(:last_error, resp)

          p "The work is done: #{sms_request.inspect}"
        else
          p "Request failed with HTTP error code "+response.code.to_s
        end

      rescue Net::ReadTimeout => exception
        STDERR.puts "ReadTimeout error"
      rescue Net::OpenTimeout => exception
        STDERR.puts "OpenTimeout error"
      end
    end
  end
end
