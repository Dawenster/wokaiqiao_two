module Cloopen
  class Conference

    def initialize
      @sig_parameter, @authorization = Sign.generate_sig_and_auth
      @header = {
        "Content-type"  => "application/xml;charset=utf-8;",
        "Accept"        => "application/xml;",
        "Authorization" => @authorization
      }
    end

    def create_conference(maxmember = 3)
      payload = <<-eos
        <?xml version='1.0' encoding='utf-8'?>
        <Request>
          <Appid>8a216da855ce635b0155cf988a540083</Appid>
          <CreateConf action='createconfresult.jsp' maxmember='#{maxmember}'/>
        </Request>
      eos
      # Clean up newline and double spaces
      payload.gsub!("\n", "").gsub!("  ", "")
      Hash.from_xml(RestClient.post url("createconf"), payload, @header)["Response"]
    end

    def url(action)
      @url = "#{Cloopen::Controller.base_uri}/ivr/#{action}?sig=#{@sig_parameter}"
    end

  end
end