require 'sinatra'
require 'sinatra/activerecord'
require 'rack/env'
require 'pg'
require 'json'
require './sms_request'


use Rack::Env, envfile: '/home/lekastillo/projects/developer.sv/sinatra_webhook/.env'
set :environment, :production
class App < Sinatra::Base

  get '/' do
    if params["dui"].blank? or params["phone"].blank?
      resp= 'Missing params'
      status = 400
    else
      
      phone = params["phone"].strip
      dui = params["dui"].strip
      
      # Chekamos si ya hubo una solicitud pendiente
      sms_requests=SmsRequest.where(dui: dui, status: 0)
      
      if sms_requests.size == 0
        puts "::::::::::::::::::::::::::::::::::::::::::::::::::: Request no encontrado \n"
        new_request=SmsRequest.create(dui: dui, phone: phone)
        resp = "request creada"
        status = 200
        
      else
        puts "::::::::::::::::::::::::::::::::::::::::::::::::::: Hay una request activa \n"
        resp = "Hay una solicitud activa"
        status = 200
      end
    end
    
    content_type :json
    halt status, { message: resp, }.to_json
  end

end

