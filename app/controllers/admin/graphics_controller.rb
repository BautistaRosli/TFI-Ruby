class Admin::GraphicsController < ApplicationController
  def index
    @inactive_properties = User.where(is_active: true).group_by_week(:created_at).count
    @active_properties = User.where(is_active: false).group_by_week(:created_at).count
    puts @inactive_properties
  end
end
