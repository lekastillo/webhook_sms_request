require "sidekiq"
require 'rack/env'
require "net/http"
require "json"
require "sinatra/activerecord"
require_relative "../models/sms_request"
require_relative "../services/twilio_sms"

class SmsRequestWorker
  include Sidekiq::Worker
    
  def perform(sms_request_id)

    sms_request=SmsRequest.find(sms_request_id)
    puts ENV['SCRAPPER_SERVICE']
    if sms_request 
      uri = URI("#{ENV['SCRAPPER_SERVICE']}/#{sms_request.dui}")
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
          
          STDERR.puts "The work is done: #{sms_request.inspect}"
        else
          STDERR.puts "Request failed with HTTP error code "+response.code.to_s
          resp = "Request failed with HTTP error code "+response.code.to_s
        end

      rescue Net::ReadTimeout => exception
        resp = "ReadTimeout error"
        STDERR.puts resp
      rescue Net::OpenTimeout => exception
        resp = "OpenTimeout error"
        STDERR.puts resp
      ensure
        sms_request.update_column(:last_error, resp)
        sms_request.update_column(:attempts, sms_request.attempts+1)
      end
    end
  end
end
