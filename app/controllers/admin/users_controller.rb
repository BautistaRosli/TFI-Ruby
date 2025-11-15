
class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  layout "admin_users"
  def index
    @users = can?(:delete, User) ? User.page(params[:page]).per(10) : User.where(is_active: true).page(params[:page]).per(10)
  end


  def show(method: :patch)
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: "Usuario actualizado correctamente."
    else
      redirect_to admin_user_path(@user), alert: "El usuario no pudo ser actualizado."
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(creation_params)
    if @user.save
      redirect_to admin_users_path, notice: "Usuario creado correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.update(is_active: false)
    redirect_to admin_users_path, notice: "Usuario desactivado correctamente."
  end

  def reactivate(method: :patch)
    @user = User.find(params[:id])
    @user.update(is_active: true)
    redirect_to admin_users_path, notice: "Usuario reactivado correctamente."
  end

  private

  def creation_params
    params.require(:user).permit(:email, :name, :lastname, :role, :is_active, :password, :password_confirmation)
  end

  def user_params
    params.require(:user).permit(:email, :name, :lastname, :role, :is_active)
  end
end
