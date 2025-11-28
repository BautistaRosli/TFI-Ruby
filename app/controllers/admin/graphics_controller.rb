class Admin::GraphicsController < ApplicationController
  def index
    # is_active: false son las INACTIVAS
    @inactive_properties = User.where(is_active: false).group_by_day(:created_at).count

    # is_active: true son las ACTIVAS
    @active_properties = User.where(is_active: true).group_by_day(:created_at).count
  end
end
