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
        put :change_password
        get :see_password
      end
    end

    resources :graphics

    resources :genres, except: [ :show ]
    resources :sales, only: [ :index, :show, :new, :create, :destroy ] do
      collection do
        get  :cart
        post :add_item
        delete :remove_item
        delete :clear_cart
      end
    end


    resources :disks do
      member do
        patch :soft_delete
        patch :set_cover
        get  :images
        post :add_image
        delete :remove_image
      end
    end

    resources :clients do
      collection do
        get :search_by_document
        get :check_email
      end
    end
  end

  namespace :disk do
    resources :new,  only: [ :index, :show ]
    resources :used, only: [ :index, :show ]
  end

  get "up" => "rails/health#show", as: :rails_health_check

  #
  # Landing page = /disk/new#index
  #
  root to: "disk/new#index"

  match "*path", to: "application#routing_error", via: :all,
    constraints: lambda { |req| !req.path.start_with?("/rails/active_storage") }

end
