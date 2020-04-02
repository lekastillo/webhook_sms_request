require 'sinatra'
require 'sinatra/activerecord'
require 'pg'
require 'json'
require_relative './models/sms_request'

class App < Sinatra::Base
  get '/' do
    if params["AccountSid"].present? and params["MessageSid"].present? and params["Body"].present? and params["From"].present?
      resp=SmsRequest.save_sms_request(params["From"], params["Body"])
    elsif params["dui"].present? and params["phone"].present?
      resp=SmsRequest.save_sms_request(params["phone"], params["dui"])
    else
      resp = { message: 'Invalid Params', status: 400}
    end
    
    content_type :json
    halt status, resp.to_json
  end

end

