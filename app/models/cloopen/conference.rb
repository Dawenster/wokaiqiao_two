module Cloopen
  module Conference

    def self.create_conference(maxmember = 3)
      sig_parameter, authorization = Sign.generate_sig_and_auth
      url = "#{Cloopen::Controller.base_uri}/ivr/createconf?sig=#{sig_parameter}&maxmember=#{maxmember}"

      payload = <<-eos
        <?xml version='1.0' encoding='utf-8'?>
        <Request>
          <Appid>8a216da855ce635b0155cf988a540083</Appid>
          <CreateConf action='createconfresult.jsp' maxmember='#{maxmember}'/>
        </Request>
      eos
      # Clean up newline and double spaces
      payload.gsub!("\n", "").gsub!("  ", "")

      header = {
        "Content-type"  => "application/xml;charset=utf-8;",
        "Accept"        => "application/xml;",
        "Authorization" => authorization
      }

      res = Hash.from_xml(RestClient.post url, payload, header)["Response"]
    end
    
  end
end