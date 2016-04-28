module NavHelper
  def nav_list
    [
      {
        text: "找专家",
        link: experts_path,
        method: :get
      },
      {
        text: "常见问题 + 提示",
        link: faq_path,
        method: :get
      },
      {
        text: "合作伙伴",
        link: partners_path,
        method: :get
      }
    ]
  end

  def not_logged_in_user_actions_list
    [
      {
        text: "注册",
        link: new_user_registration_path,
        method: :get
      },
      {
        text: "快速登入",
        link: new_user_session_path,
        method: :get
      }
    ]
  end

  def logged_in_user_dropdown_list
    [
      {
        text: "个人主页",
        link: user_path(current_user),
        method: :get
      },
      {
        text: "通话会议",
        link: calls_path,
        method: :get
      },
      {
        text: "折扣代码",
        link: promotions_path,
        method: :get
      },
      {
        text: "修改用户",
        link: edit_user_registration_path,
        method: :get
      },
      {
        text: "登出",
        link: destroy_user_session_path,
        method: :delete
      }
    ]
  end
end
