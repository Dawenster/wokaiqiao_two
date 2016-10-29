module Cloopen
  module Controller
    def self.base_uri
      # if Rails.env.production?
      #   base_uri = "https://app.cloopen.com:8883/2013-12-26/Accounts/"
      # else
      #   base_uri = "https://sandboxapp.cloopen.com:8883/2013-12-26/Accounts/"
      # end
      base_uri = "https://sandboxapp.cloopen.com:8883/2013-12-26/Accounts/"
      "#{base_uri}#{ENV["CLOOPEN_ACCOUNT_SID"]}"
    end

    def self.clean_up_payload(payload)
      payload.gsub("\n", "").gsub("  ", "")
    end

    def self.parse_time(time_string)
      # E.g. 20161012103559 => Oct. 12, 2016 at 10:35:59
      Time.strptime("#{time_string}+0800", "%Y%m%d%H%M%S%z")
    end
  end
end