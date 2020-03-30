class SmsRequest < ActiveRecord::Base
  self.table_name = "sms_requests"
  validates :phone, :dui, presence: true
  
  def self.save_sms_request(param_phone, param_dui)
    request_phone = param_phone.strip
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