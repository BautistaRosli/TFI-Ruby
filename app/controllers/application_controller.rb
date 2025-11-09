class ApplicationController < ActionController::Base
  def after_sign_in_path_for(resource)
    admin_dashboard_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  def authenticate_user!
    unless user_signed_in?
      redirect_to new_user_session_path, alert: "Por favor, inicia sesión para continuar."
    end
  end
end
