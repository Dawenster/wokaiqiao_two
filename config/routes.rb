Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users, :controllers => {
    :registrations => "custom_devise/registrations",
    :passwords => "custom_devise/passwords"
  }

  root to: "pages#landing"

  get "faq" => "pages#faq", as: :faq
  get "partners" => "pages#partners", as: :partners

  scope "experts" do
    get "/" => "experts#index", as: :experts
    get "book/:expert_id" => "experts#book", as: :book_expert
  end

  resources :calls, only: [:create]
end
