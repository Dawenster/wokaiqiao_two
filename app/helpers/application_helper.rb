module ApplicationHelper
  def team_email
    "team@wokaiqiao.com"
  end

  def contact_email
    "contact@wokaiqiao.com"
  end

  def become_expert_email
    "experts@wokaiqiao.com"
  end

  def become_expert_email_body_content
    "
      联络资料 (邮箱 (我开窍的登入邮箱）, 微信户名, 或手机号):\n
      现在就职:\n
      所在城市:\n
      如果您是被我们的专家推荐成为我开窍专家，请填写他 / 她的名字:\n
      \n
      谢谢您申请成为我们的专家，我们会尽快与您联系。我们可能会要求您提供更多个人资料以验证您的身份。\n
      \n
      我们致力确保专家的质量和真确性以及为用户提供一个多元的专家库。
    "
  end

  def rails_admin_link(record)
    rails_admin.show_path(model_name: record.class.name.downcase, id: record.id)
  end
end
