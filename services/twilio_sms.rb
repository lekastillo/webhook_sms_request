require 'rubygems'
require 'rack/env'
require 'twilio-ruby'

class TwilioSms

  def self.send_sms(phone, message)
    # begin
      puts "::::::::::::::::::::::::::::::::::::::::::::::::::: Twilio \n"
      client = Twilio::REST::Client.new('ACCOUNT SID', 'AUTH TOKEN')
      result=client.messages.create(
        from: 'NUMBER',
        to: phone,
        body: message
        )
      puts "::::::::::::::::::::::::::::::::::::::::::::::::::: #{result.inspect} \n"
      return result.try(:sid)
    # rescue
    #   return false
    # end
  end
end

# To SEND       TwilioSms.send_sms(number, message)
# To SEND       TwilioSms.send_sms('+50379900988', 'Hello friend')
