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
end
