require "net/http"
require "json"
require "sidekiq"
require "rack/env"
require "sinatra/activerecord"
require_relative "../models/sms_request"
require_relative "../services/twilio_sms"

Sidekiq.configure_server do |config|
  config.redis = { url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}" }
end
class SmsRequestWorker
  include Sidekiq::Worker
  
  def perform(sms_request_id)
    puts "::::::::::::::::::::::::::::::::::::::::::::::::::: Worker doing something \n"
    sms_request=SmsRequest.find(sms_request_id)

    if sms_request 
      uri = URI(ENV['SCRAPPER_ENDPOINT']+sms_request.dui)
      timeout = ENV['SCRAPPER_REQUEST_TIMEOUT'].to_i 

      Net::HTTP.start(uri.host,uri.port,
                    :use_ssl => uri.scheme == 'https',
                    :read_timeout => timeout) do |http|
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
        p "Request failed by HTTP error: "+response.code.to_s
      end
    end
  end
end
