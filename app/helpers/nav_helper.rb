module NavHelper
  def nav_list
    [
      {
        text: "找专家",
        link: experts_path
      },
      {
        text: "常见问题 + 提示",
        link: faq_path
      },
      {
        text: "合作伙伴",
        link: partners_path
      }
    ]
  end

  def not_logged_in_user_actions_list
    [
      {
        text: "注册",
        link: "#"
      },
      {
        text: "快速登入",
        link: "#"
      }
    ]
  end

  def logged_in_user_dropdown_list
    [
      {
        text: "个人主页",
        link: "#"
      }
    ]
  end
end
