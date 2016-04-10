module CallsHelper
  def callout_class(call)
    case call.status
    when Call::PENDING_EXPERT_ACCEPTANCE
      "secondary"
    when Call::PENDING_USER_ACCEPTANCE
      "warning"
    when Call::MUTUALLY_ACCEPTED
      "success"
    end
  end

  def link_to_accept(call, datetime_num)
    str = " - "
    str += link_to "接受", accept_call_path(call, acceptor: current_user.role_in(call), datetime_num: datetime_num), method: :post
  end
end
