Rails.application.routes.draw do
  default_url_options Rails.application.config.action_mailer.default_url_options
  
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users, :controllers => {
    :registrations => "custom_devise/registrations",
    :passwords => "custom_devise/passwords"
  }

  root to: "pages#landing"

  get "faq" => "pages#faq", as: :faq
  get "partners" => "pages#partners", as: :partners
  get "copyright-and-trademark" => "pages#copyright_and_trademark", as: :copyright_and_trademark
  get "disclaimer" => "pages#disclaimer", as: :disclaimer
  get "privacy-policy" => "pages#privacy_policy", as: :privacy_policy
  get "service-agreement" => "pages#service_agreement", as: :service_agreement

  scope "experts" do
    get "/" => "experts#index", as: :experts
    get "book/:expert_id" => "experts#book", as: :book_expert
  end

  resources :users, only: [:show, :update]
  resources :calls, only: [:create, :update, :index] do
    member do
      post :accept
      post :rate
      get  :rate_with_rating
      post :cancel
    end
  end
  resources :promotions, only: [:index] do
    collection do
      post :check
    end
  end
  resources :partnership_requests, only: [:create]

  namespace :webhooks do
    scope "cloopen" do
      post :create_conference_succeeded
      post :conference_ended
    end
  end
end
