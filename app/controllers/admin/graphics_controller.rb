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
    @top_customer = Sale.top_customer
    @sales_by_hour = Sale.sales_by_hour
    @low_stock = NewDisk.low_stock

    # Reportes personalizados
    if params[:report_type].present? && params[:search_query].present?

      @report_type = params[:report_type]
      query = params[:search_query].strip

      case @report_type
      when "employee"
        @custom_entity = User.find_by(email: query)
        if @custom_entity
          sales = Sale.where(user_id: @custom_entity.id, deleted: [ false, nil ]) # Cambiar

          @custom_chart_1 = sales.group_by_week(:datetime).sum(:total_amount)
          @custom_chart_2 = Disk.joins(items: :sale).where(sales: { id: sales.ids }).group(:format).count
          @custom_kpi = sales.sum(:total_amount)
        else
          flash.now[:alert] = "No se encontró empleado con email: #{query}"
        end

      when "client"
        # Buscamos cliente por DNI
        @custom_entity = Client.find_by(document_number: query)
        puts "HOLAAAAAAAAAAAAAA"
        puts @custom_entity
        puts @custom_entity.id
        puts query
        if @custom_entity
          sales = Sale.where(customer_id: @custom_entity.id, deleted: [ false, nil ])

          @custom_chart_1 = sales.group_by_day(:created_at).count

          @custom_chart_2 = Disk.joins(items: :sale).where(sales: { id: sales.ids }).group(:category).count
          @custom_kpi = sales.average(:total_amount)
        else
          flash.now[:alert] = "No se encontró cliente con DNI: #{query}"
        end

      when "category"
        query = query.downcase.capitalize # Paso a min y despues pongo la primer letra en mayus
        if Disk.exists?(category: query)
          @custom_entity = query
          sales = Sale.joins(items: :disk).where(disks: { category: query }, deleted: [ false, nil ])


          @custom_chart_1 = sales.group_by_month(:datetime).sum(:total_amount)
          @custom_chart_2 = Disk.where(category: query).joins(:items).group(:name).sum("items.units_sold").sort_by { |_, v| -v }.first(5)
          @custom_kpi = sales.sum(:total_amount)
        else
          flash.now[:alert] = "No existe la categoría: #{query}"
        end
      end
    end
  end
end
