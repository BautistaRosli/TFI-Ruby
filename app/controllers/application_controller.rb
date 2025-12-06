class ApplicationController < ActionController::Base
  def after_sign_in_path_for(resource)
    admin_dashboard_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  def authenticate_user!
    unless user_signed_in?

      path = request.path.chomp("/") # Quita la barra final si existe (/admin/ -> /admin)

      # Permitimos que vaya al login para que pueda entrar
      if path == "/admin"
        store_location_for(:user, request.fullpath)
        redirect_to new_user_session_path, alert: "Por favor, inicia sesión para acceder al panel."

      elsif path.start_with?("/admin")
        redirect_to root_path, alert: "La página que buscas no existe."
      else
        store_location_for(:user, request.fullpath)
        redirect_to new_user_session_path, alert: "Por favor, inicia sesión para continuar."
      end
    end
  end

  def routing_error
    redirect_to root_path, alert: "La página que buscas no existe."
  end

  rescue_from CanCan::AccessDenied do |exception|
    previous_url = default_redirect_path
    flash[:alert] = "No tenés permisos para acceder a esa página."
    redirect_to previous_url
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    flash[:alert] = "El recurso que estás buscando no existe."
    previous_url = request.referer || default_redirect_path
    redirect_to previous_url
  end

    # agrego esto para manejar error con la session
    rescue_from ActionController::InvalidAuthenticityToken do |exception|
      flash[:alert] = "Hubo un problema con la sesión."
      redirect_to new_user_session_path
    end


  private
  def default_redirect_path
    if current_user
      admin_dashboard_path

    else
      root_path
    end
  end
end
