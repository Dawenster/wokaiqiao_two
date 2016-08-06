module Cloopen
  class Sign
    # 生成验证参数
    # 1. SigParameter
    # 2. Authorization
    def self.generate_sig_and_auth
      time = Time.now.strftime("%Y%m%d%H%M%S")
      sig_parameter = Digest::MD5.hexdigest(ENV["CLOOPEN_ACCOUNT_SID"] + ENV["CLOOPEN_AUTH_TOKEN"] + time).upcase
      authorization = Base64.strict_encode64("#{ENV["CLOOPEN_ACCOUNT_SID"]}:#{time}")
      [sig_parameter, authorization]
    end

  end
end