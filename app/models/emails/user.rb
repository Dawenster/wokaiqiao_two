module Emails
  class User

    def self.send_welcome(user)
      begin
        obj = Emails::Setup.send_with_us_obj

        result = obj.send_email(
          "tem_BRuKBD9wJR7Di8knEsMY6d",
          { address: user.email },
          data: {
            name: user.name
          }
        )
      rescue => e
        puts "Error - #{e.class.name}: #{e.message}"
      end
    end

  end
end