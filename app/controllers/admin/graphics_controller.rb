class Admin::GraphicsController < ApplicationController
  def index
    @sales_by_disks = Disk.sold_in_active_sales.group(:name).count

    @revenue_by_week = Sale.revenue_by_week
  end
end
