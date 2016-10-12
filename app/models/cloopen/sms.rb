module Cloopen
  class Sms

    def initialize
      @sig_parameter, @authorization = Sign.generate_sig_and_auth
      @header = {
        "Content-type"  => "application/xml;charset=utf-8;",
        "Accept"        => "application/xml;",
        "Authorization" => @authorization
      }
    end

    def call_starting_reminder(number, other_persons_name, call)
      payload = <<-eos
        <?xml version='1.0' encoding='utf-8'?>
        <TemplateSMS>
          <to>#{number}</to>
          <appId>#{ENV["CLOOPEN_APP_ID"]}</appId> 
          <templateId>122856</templateId>
          <datas>
            <data>#{other_persons_name}</data>
            <data>#{call.conference_call_number}</data>
            <data>#{call.conference_call_participant_code}</data>
          </datas>
        </TemplateSMS>
      eos
      # Clean up newline and double spaces
      payload = Cloopen::Controller.clean_up_payload(payload)
      full_url = url
      Hash.from_xml(RestClient.post full_url, payload, @header)["Response"]
    end

    private

    def url(options = {})
      action_url = "#{Cloopen::Controller.base_uri}/SMS/TemplateSMS?sig=#{@sig_parameter}"
      options.each do |key, value|
        action_url += "&#{key}=#{value}"
      end
      action_url
    end

  end
end