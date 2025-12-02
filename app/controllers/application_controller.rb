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

  rescue_from CanCan::AccessDenied do |exception|
    previous_url = request.referer || root_path
    if current_user # Si no estas logeado no te digo que rutas existen, para mas "seguridad".
      flash[:alert] = "No tenés permisos para acceder a esa página."
    else
      flash[:alert] = "El recurso que estás buscando no existe."
    end
    redirect_to previous_url
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    flash[:alert] = "El recurso que estás buscando no existe."
    previous_url = request.referer || default_redirect_path
    redirect_to previous_url
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
