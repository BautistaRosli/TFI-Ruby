class Admin::GraphicsController < ApplicationController
  before_action :authenticate_user!
  authorize_resource class: false

  def index
    @sales_by_disks = Disk.sold_in_active_sales
    @revenue_by_week = Sale.revenue_by_week
    @employee_with_more_sales = Sale.users_by_account_of_sales
    @sales_from_cd = Sale.sales_from_cd
    @sales_from_vinilo = Sale.sales_from_vinilo
    @aov_by_day = Sale.average_sale_value_by_day
    @category_sold = Disk.category_sold
  end
end
