class Disk::NewController < ApplicationController
  layout 'disks'
  def index
    @disks = NewDisk.all.order(created_at: :desc).page(params[:page]).per(8)
  end

  def show
    @disk = NewDisk.find(params[:id])
  end
end
