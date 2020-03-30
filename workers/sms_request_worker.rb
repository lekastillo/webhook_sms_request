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
    puts "::::::::::::::::::::::::::::::::::::::::::::::::::: Worker doing somthing \n"
    sms_request=SmsRequest.find(sms_request_id)

    # GET MESSAGE
    message = "Buxos ya llegan los sms, solo falta integrar con scraping XD"

    if sms_request
      resp=TwilioSms.send_sms(sms_request.phone, message)

      sms_request.update_column(:status, 1)
      sms_request.update_column(:last_error, resp)
      p "The work is done: #{sms_request.inspect}"
    end
  end
end