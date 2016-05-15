module FooterHelper
  def footer_links
    [
      {
        type: "link",
        text: "全部专家",
        path: experts_path,
        new_tab: false
      },
      {
        type: "mail_to",
        text: "联络我们",
        mail_to: team_email
      },
      {
        type: "link",
        text: "反馈意见",
        path: "https://www.surveymonkey.com/r/K7KGTPQ",
        new_tab: true
      },
      {
        type: "link",
        text: "著作权与商标声明",
        path: copyright_and_trademark_path,
        new_tab: false
      },
      {
        type: "link",
        text: "法律声明",
        path: disclaimer_path,
        new_tab: false
      },
      {
        type: "link",
        text: "隐私政策",
        path: privacy_policy_path,
        new_tab: false
      },
      {
        type: "link",
        text: "使用条款",
        path: service_agreement_path,
        new_tab: false
      }
    ]
  end
end