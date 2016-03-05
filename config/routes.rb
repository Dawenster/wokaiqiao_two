Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users#, :controllers => { :registrations => "registrations" }
  root to: "pages#landing"

  get "faq" => "pages#faq", as: :faq
  get "partners" => "pages#partners", as: :partners

  scope "experts" do
    get "/" => "experts#index", as: :experts
    post "book" => "experts#book", as: :book_expert
  end
end
