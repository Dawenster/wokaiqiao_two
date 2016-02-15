module ApplicationHelper
  def team_email
    "team@wokaiqiao.com"
  end

  def become_expert_email
    "experts@wokaiqiao.com"
  end

  def nav_list
    [
      {
        text: "找专家",
        link: "#"
      },
      {
        text: "常见问题 + 提示",
        link: "#"
      },
      {
        text: "合作伙伴",
        link: "#"
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
