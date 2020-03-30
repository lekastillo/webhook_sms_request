require 'sidekiq'
require 'telephone_number'
require_relative "../workers/sms_request_worker"

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}" }
end

# $redis = Redis.new( url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}" )

class SmsRequest < ActiveRecord::Base
  self.table_name = "sms_requests"
  validates :phone, :dui, presence: true

  after_create :send_request_to_sidekiq

  def send_request_to_sidekiq
    # sleep 10
    SmsRequestWorker.perform_in(2.seconds, self.id)
  end
  
  def self.save_sms_request(param_phone, param_dui)

    # request_phone = TelephoneNumber.parse(param_phone.strip, :sv).e164_number
    request_phone = param_phone
    request_dui = param_dui.gsub('-','').gsub('_','').strip
      
      # Chekamos si ya hubo una solicitud pendiente
      sms_requests=SmsRequest.where(dui: request_dui, status: 0)
      
      if sms_requests.size == 0
        puts "::::::::::::::::::::::::::::::::::::::::::::::::::: Request no encontrado \n"
        new_request=SmsRequest.create(dui: request_dui, phone: request_phone)
        resp = {message: "request creada", status: 200 }
      else
        puts "::::::::::::::::::::::::::::::::::::::::::::::::::: Hay una request activa \n"
        resp = {message: "request activa encontrada", status: 200 }
      end
      
      return resp
  end
  
end

# string :phone, null: false, default: ""
# string :dui, null: false, default: ""
# integer :status, default: 0
# integer :priority, default: 0
# integer :attempts, default: 0
# text :last_error, default: 0
# datetime :locked_at
# SmsRequest.save_sms_request(param_phone, param_dui)