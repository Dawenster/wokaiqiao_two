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
      callback = Rails.application.routes.url_helpers.webhooks_create_conference_succeeded_path
      del_callback = Rails.application.routes.url_helpers.webhooks_conference_ended_path
      payload = <<-eos
        <?xml version='1.0' encoding='utf-8'?>
        <Request>
          <Appid>#{ENV["CLOOPEN_APP_ID"]}</Appid>
          <CreateConf action='#{callback}' maxmember='#{maxmember}' autorecord='true' delreporturl='#{del_callback}' />
        </Request>
      eos
      # Clean up newline and double spaces
      payload = clean_up_payload(payload)
      full_url = url("createconf", {maxmember: maxmember})
      Hash.from_xml(RestClient.post full_url, payload, @header)["Response"]
    end

    def end_conference(conf_id)
      payload = <<-eos
        <?xml version='1.0' encoding='utf-8'?>
        <Request>
          <Appid>#{ENV["CLOOPEN_APP_ID"]}</Appid>
          <DismissConf confid='#{conf_id}' />
        </Request>
      eos
      # Clean up newline and double spaces
      payload = clean_up_payload(payload)
      full_url = url("conf", {confid: conf_id})
      Hash.from_xml(RestClient.post full_url, payload, @header)["Response"]
    end

    def invite_guest(conf_id, number)
      payload = <<-eos
        <?xml version='1.0' encoding='utf-8'?>
        <Request>
          <Appid>#{ENV["CLOOPEN_APP_ID"]}</Appid>
          <InviteJoinConf confid='#{conf_id}' number='#{number}' />
        </Request>
      eos
      # Clean up newline and double spaces
      payload = clean_up_payload(payload)
      full_url = url("conf", {confid: conf_id})
      Hash.from_xml(RestClient.post full_url, payload, @header)["Response"]
    end

    def query_conference_state(conf_id)
      payload = <<-eos
        <?xml version='1.0' encoding='utf-8'?>
        <Request>
          <Appid>#{ENV["CLOOPEN_APP_ID"]}</Appid>
          <QueryConfState confid='#{conf_id}' />
        </Request>
      eos
      # Clean up newline and double spaces
      payload = clean_up_payload(payload)
      full_url = url("conf", {confid: conf_id})
      Hash.from_xml(RestClient.post full_url, payload, @header)["Response"]
    end

    private

    def url(action, options)
      action_url = "#{Cloopen::Controller.base_uri}/ivr/#{action}?sig=#{@sig_parameter}"
      options.each do |key, value|
        action_url += "&#{key}=#{value}"
      end
      action_url
    end

    def clean_up_payload(payload)
      payload.gsub("\n", "").gsub("  ", "")
    end

  end
end