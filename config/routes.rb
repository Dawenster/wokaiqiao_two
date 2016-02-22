Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users
  root to: "pages#landing"

  scope "experts" do
    get "/" => "experts#index", as: :experts
    post "book" => "experts#book", as: :book_expert
  end
end
