Rails.application.routes.draw do
  # legacy routes removed; use RESTful disk namespace below
  get "home/index"

  devise_for :users,
    path: "admin",
    controllers: {
      sessions: "admin/auth/sessions"
    },
    skip: [ :sessions ]

  devise_scope :user do
    get    "admin/login",  to: "admin/auth/sessions#new",     as: :new_user_session
    post   "admin/login",  to: "admin/auth/sessions#create", as: :user_session
    get    "admin/logout", to: "admin/auth/sessions#destroy", as: :destroy_user_session
  end

  namespace :admin do
    root to: "dashboard#index", as: :dashboard

    resources :users do
      member do
        patch :reactivate
      end
    end

    resources :sales 
    resources :disks do
      member do
        patch :change_stock
      end
    end
  end

  namespace :disk do
    resources :new,  only: [:index, :show]
    resources :used, only: [:index, :show]
  end

  get "up" => "rails/health#show", as: :rails_health_check

  #
  # Landing page = /disk/new#index
  #
  root to: "disk/new#index"
end
