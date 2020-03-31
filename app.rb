require 'sinatra'
require 'sinatra/activerecord'
require 'rack/env'
require 'pg'
require 'json'
require_relative './models/sms_request'

# set :environment, ENV['APP_ENV']
use Rack::Env, envfile: '/home/lekastillo/projects/developer.sv/sinatra_webhook/.env' unless ENV['RACK_ENV'] == 'production'

puts "======================> database URL: #{ENV['RACK_ENV']}"

class App < Sinatra::Base

  get '/' do

    puts params.inspect

    if params["AccountSid"].present? and params["MessageSid"].present? and params["Body"].present? and params["From"].present?
      resp=SmsRequest.save_sms_request(params["From"], params["Body"])
    elsif params["dui"].present? and params["phone"].present?
      puts "#{params["phone"]} \n"
      resp=SmsRequest.save_sms_request(params["phone"], params["dui"])
    else
      resp = { message: 'Invalid Params', status: 400}
    end
    
    content_type :json
    halt status, { message: resp, }.to_json
  end

end

