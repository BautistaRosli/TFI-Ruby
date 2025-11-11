Rails.application.routes.draw do
  get "home/index"

  devise_for :users,
    path: "admin",
    controllers: {
      sessions: "admin/auth/sessions"
    },
    skip: [ :sessions ]


  devise_scope :user do
    get    "admin/login",  to: "admin/auth/sessions#new", as: :new_user_session
    post   "admin/login",  to: "admin/auth/sessions#create", as: :user_session
    get "admin/logout", to: "admin/auth/sessions#destroy", as: :destroy_user_session
  end

  namespace :admin do
    root to: "dashboard#index", as: :dashboard
    resources :users, module: :users
    resources :users
  end

  get "up" => "rails/health#show", as: :rails_health_check
  root to: "home#index"
end
