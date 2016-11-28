class Alipay::Pay

  CURRENCY = "CNY"

  def initialize(call, amount, callback_url)
    @call = call
    @subject = "与#{@call.expert.name}通话"
    @amount = amount / 100
    @callback_url = callback_url
  end

  def run!
    url = Alipay::Service.create_direct_pay_by_user_url(
      out_trade_no: @call.id,
      subject: @subject,
      total_fee: @amount.to_f,
      currency: CURRENCY,
      return_url: @callback_url,
      notify_url: @callback_url
    )
    url = url.gsub("https://mapi.alipay.com/gateway.do", "https://openapi.alipaydev.com/gateway.do") if !Rails.env.production?
    url
  end

end
