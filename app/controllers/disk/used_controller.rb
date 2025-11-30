class Disk::UsedController < ApplicationController
  layout 'disks'

  def index
    @disks = UsedDisk.all.order(created_at: :desc).page(params[:page]).per(8)
  end

  def show
    @disk = UsedDisk.find(params[:id])
  end
end
