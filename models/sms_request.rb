require 'sidekiq'
require 'telephone_number'
require_relative "../workers/sms_request_worker"

class SmsRequest < ActiveRecord::Base
  self.table_name = "sms_requests"
  validates :phone, :dui, presence: true

  after_create :send_request_to_sidekiq

  def send_request_to_sidekiq
    SmsRequestWorker.perform_in(2.seconds, self.id)
  end
  
  def self.save_sms_request(param_phone, param_dui)

    request_phone = TelephoneNumber.parse(param_phone.strip).e164_number
    request_dui = param_dui.gsub('-','').gsub('_','').strip
      
      # Chekamos si ya hubo una solicitud pendiente
      sms_requests=SmsRequest.where(dui: request_dui, status: 0)
      
      if sms_requests.size == 0
        new_request=SmsRequest.create(dui: request_dui, phone: request_phone)
        resp = {message: "request creada", status: 200 }
      else
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