class Alipay::Pay

  CURRENCY = "CNY"
  DESKTOP = "desktop"
  MOBILE = "mobile"

  def initialize(call, amount, callback_url, is_mobile)
    @call = call
    @subject = "与#{@call.expert.name}通话"
    @amount = amount / 100
    @callback_url = callback_url
    @device = is_mobile ? MOBILE : DESKTOP
  end

  def run!
    if @device == DESKTOP
      url = desktop_url
    else
      url = mobile_url
    end
    url = url.gsub("https://mapi.alipay.com/gateway.do", "https://openapi.alipaydev.com/gateway.do") if !Rails.env.production?
    url
  end

  def desktop_url
    Alipay::Service.create_direct_pay_by_user_url(
      out_trade_no: @call.id,
      subject: @subject,
      total_fee: @amount.to_f,
      currency: CURRENCY,
      return_url: @callback_url,
      notify_url: @callback_url
    )
  end

  def mobile_url
    Alipay::Service.create_direct_pay_by_user_wap_url(
      out_trade_no: @call.id,
      subject: @subject,
      total_fee: @amount.to_f,
      currency: CURRENCY,
      return_url: @callback_url,
      notify_url: @callback_url
    )
  end

end
