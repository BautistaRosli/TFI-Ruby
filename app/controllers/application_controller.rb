class ApplicationController < ActionController::Base
  def after_sign_in_path_for(resource)
    admin_dashboard_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  def authenticate_user!
    # Permitir recursos estáticos y blobs de Active Storage sin autenticación
    path = request.path.chomp("/")

    if path.start_with?("/rails/active_storage") || path.start_with?("/assets") || path.start_with?("/packs")
      return
    end

    unless user_signed_in?
      # Quita la barra final si existe (/admin/ -> /admin)
      # path ya normalizado arriba

      # Permitimos que vaya al login para que pueda entrar
      if path == "/admin"
        redirect_to new_user_session_path, alert: "Por favor, inicia sesión para acceder al panel."
      elsif path.start_with?("/admin")
        redirect_to root_path, alert: "La página que buscas no existe."
      else
        redirect_to new_user_session_path, alert: "Por favor, inicia sesión para continuar."
      end
    end
  end

  def routing_error
    redirect_to root_path, alert: "La página que buscas no existe."
  end

  rescue_from CanCan::AccessDenied do |exception|
    previous_url = request.referer || default_redirect_path
    flash[:alert] = "No tenés permisos para acceder a esa página."
    redirect_to previous_url
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    if request.path.start_with?("/rails/active_storage")
      raise exception
    end
    flash[:alert] = "El recurso que estás buscando no existe."
    previous_url = request.referer || default_redirect_path
    redirect_to previous_url
  end

  rescue_from ActionController::InvalidAuthenticityToken do |exception|
    if request.path.start_with?("/rails/active_storage")
      raise exception
    end
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
