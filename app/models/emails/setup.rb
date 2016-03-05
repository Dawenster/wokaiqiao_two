module Emails
  class Setup

    def self.send_with_us_obj
      SendWithUs::Api.new( api_key: ENV["SENDWITHUS_API_KEY"], debug: true )
    end

  end
end