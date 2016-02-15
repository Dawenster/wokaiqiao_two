RailsAdmin.config do |config|

  require 'i18n'
  I18n.default_locale = :en

  config.main_app_name = Proc.new { |controller| [ "我开窍", "大奶頭管理區" ] }

  ### Popular gems integration

  ## == Devise ==
  config.authorize_with do |controller|
    unless current_user.try(:admin)
      redirect_to main_app.root_path
    end
  end
  config.current_user_method(&:current_user)

  ## == Cancan ==
  # config.authorize_with :cancan

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end
end
