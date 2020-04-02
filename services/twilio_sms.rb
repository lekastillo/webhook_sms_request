require 'rubygems'
require 'rack/env'
require 'twilio-ruby'

class TwilioSms

  def self.send_sms(phone, message)
    begin
      client = Twilio::REST::Client.new(ENV['ACCOUNT SID'], ENV['AUTH TOKEN'])
      result=client.messages.create(
        from: ENV['NUMBER'],
        to: phone,
        body: message
        )
      return result.try(:sid)
    rescue
      return result
    end
  end
end

# To SEND       TwilioSms.send_sms(number, message)
# To SEND       TwilioSms.send_sms('+50379900988', 'Hello friend')
