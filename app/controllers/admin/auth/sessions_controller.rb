# frozen_string_literal: true
module Admin
  class Auth::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

    def new
      super
    end

    def create
      super
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