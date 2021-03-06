module Emails
  class User

    def self.admin_emails
      ::User.admin.map do |user|
        {
          name: user.name,
          address: user.email
        }
      end
    end

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
        Rollbar.error(e)
      end
    end

    def self.reset_password(user, reset_link)
      begin
        obj = Emails::Setup.send_with_us_obj

        result = obj.send_email(
          "tem_HQphnSk5Jhyc4xb9xooShm",
          { address: user.email },
          data: {
            receiver_name: user.name || user.email,
            reset_link: reset_link
          }
        )
      rescue => e
        Rollbar.error(e)
      end
    end

  end
end