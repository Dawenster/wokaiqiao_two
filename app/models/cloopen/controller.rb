module Cloopen
  module Controller
    def self.base_uri
      if Rails.env == "production"
        base_uri = "https://app.cloopen.com:8883/2013-12-26/Accounts/"
      else
        base_uri = "https://sandboxapp.cloopen.com:8883/2013-12-26/Accounts/"
      end
      "#{base_uri}#{ENV["CLOOPEN_ACCOUNT_SID"]}"
    end
  end
end