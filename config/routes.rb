Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin', locale: "en"
  devise_for :users
  root to: "pages#landing"
end
