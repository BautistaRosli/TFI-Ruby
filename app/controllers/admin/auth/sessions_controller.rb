# frozen_string_literal: true

module Admin
  class Auth::SessionsController < Devise::SessionsController
    # before_action :configure_sign_in_params, only: [:create]

    def new
      super
    end

    def create
      super do |user|
        if !user.is_active
          sign_out user
          flash[:alert] = "Tu cuenta no está activa. Por favor, contacta al administrador."
          redirect_to new_user_session_path and return
        end
      end
      if user_signed_in?
        flash[:notice] = "Inicio de sesión exitoso."
      end
    end


    def destroy
      super
      flash[:notice] = "Cierre de sesión exitoso."
    end

    # protected

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_sign_in_params
    #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
    # end
  end
end
