class SmsRequest < ActiveRecord::Base
  self.table_name = "sms_requests"
  validates :phone, :dui, presence: true
  
end

# string :phone, null: false, default: ""
# string :dui, null: false, default: ""
# integer :status, default: 0
# integer :priority, default: 0
# integer :attempts, default: 0
# text :last_error, default: 0
# datetime :locked_at