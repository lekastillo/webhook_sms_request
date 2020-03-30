require 'net/http'
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
    # TODO: Add endpoint as parameter
    uri = URI('https://sms-scrapper.rover.quenecesito.org/sms/'+sms_request.dui)
    # TODO: Add timeout or cancel
    Net::HTTP.start(uri.host,uri.port,
                    :use_ssl => uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new uri
      response = http.request request
    end

    # TODO: Process response or enqueue again in case of error
    message = response.read_body

    if sms_request
      resp=TwilioSms.send_sms(sms_request.phone, message)

      sms_request.update_column(:status, 1)
      sms_request.update_column(:last_error, resp)
      p "The work is done: #{sms_request.inspect}"
    end
  end
end
