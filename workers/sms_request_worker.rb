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

    sms_request = SmsRequest.find(sms_request_id)

    if sms_request
      uri = URI("#{ENV['SCRAPPER_ENDPOINT']}/#{sms_request.dui}")
    
      begin 
        # TODO: Add timeout as parameter
        Net::HTTP.start(uri.host,uri.port,
                      :use_ssl => uri.scheme == 'https',
                      :read_timeout => 10,
                      :open_timeout => 10) do |http|
          request = Net::HTTP::Get.new uri
          response = http.request request
        end

        if response.code == 200
          # TODO: Process response or enqueue again in case of error
          message = response.read_body

          resp=TwilioSms.send_sms(sms_request.phone, message)

          sms_request.update_column(:status, 1)
          sms_request.update_column(:last_error, resp)

          p "The work is done: #{sms_request.inspect}"
        else
          p "Request failed: #{sms_request.inspect}"
        end
      rescue Net::ReadTimeout => exception
        STDERR.puts "ReadTimeout error"
      rescue Net::OpenTimeout => exception
        STDERR.puts "OpenTimeout error"
      end
    end
  end
end
