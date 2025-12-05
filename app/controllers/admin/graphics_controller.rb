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
    @deleted_sales = Sale.deleted_sales
    @anonymous = Client.find_by(document_number: "000000", document_type: "DNI")

    if @anonymous
      anon_sales = Sale.anonymous_sales(@anonymous.id)
      @anonymous_qty_chart = anon_sales.group_by_week(:created_at).count
      @anonymous_money_chart = anon_sales.group_by_week(:created_at).sum(:total_amount)
      @total_anonymous_revenue = anon_sales.sum(:total_amount)
    else
      @anonymous_qty_chart = {}
      @anonymous_money_chart = {}
      @total_anonymous_revenue = 0
    end

    # Reportes personalizados
    if params[:report_type].present? && params[:search_query].present?

      @report_type = params[:report_type]
      query = params[:search_query].strip

      case @report_type
      when "employee"
        @custom_entity = User.find_by(email: query)
        if @custom_entity
          sales = Sale.sales_by_employee(@custom_entity.id)

          @custom_chart_1 = sales.group_by_week(:created_at).sum(:total_amount)
          @custom_chart_2 = Disk.format_in_sales(sales)
          @custom_kpi = sales.sum(:total_amount)
        else
          flash.now[:alert] = "No se encontró empleado con email: #{query}"
        end

      when "client"
        @custom_entity = Client.find_by(
          document_number: query,
          document_type: params[:document_type]
        )
        if @custom_entity
          sales = Sale.sales_by_customer(@custom_entity.id)

          @custom_chart_1 = sales.group_by_day(:created_at).count

          @custom_chart_2 = Disk.gender_sold(sales)
          @custom_kpi = sales.average(:total_amount)
        else
          flash.now[:alert] = "No se encontró al cliente"
        end

      when "category"
        query = query.downcase.capitalize


        genre = Genre.find_by(name: query)

        if genre
          @custom_entity = genre.name


          sales = Sale.sales_by_gender(query)

          @custom_chart_1 = sales.group_by_month(:created_at).sum(:total_amount)


          @custom_chart_2 = Disk.ranking_by_gender(query)

          @custom_kpi = sales.sum(:total_amount)
        else
          flash.now[:alert] = "No existe la categoría: #{query}"
        end
      end
    end
  end
end
