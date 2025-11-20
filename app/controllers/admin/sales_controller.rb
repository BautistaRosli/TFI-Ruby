class Admin::SalesController < ApplicationController
  layout 'admin'
  
  #Llevar al modelo. las deleted. El order y el page, esta bien.
  def index
    @sales = Sale.where(deleted: false).order(created_at: :asc).page(params[:page]).per(3 )
  end

  def show
    @sale = Sale.includes(items: :disk).find(params[:id])
  end

  def new
  end

  def edit
  end

  def create
  end

  def update
  end

  def destroy
    @sale = Sale.find(params[:id])
    
    # Borrado lógico: actualiza deleted a true
    if @sale.update(deleted: true)
      redirect_to admin_sales_path, notice: "Venta eliminada correctamente"
    else
      redirect_to admin_sales_path, alert: "No se pudo eliminar la venta"
    end
  end
end
