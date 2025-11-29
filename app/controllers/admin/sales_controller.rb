class Admin::SalesController < ApplicationController
  layout 'admin'
  
  def index
    @sales = Sale.where(deleted: false).order(created_at: :asc).page(params[:page]).per(3 )
  end

  def show
    @sale = Sale.includes(items: :disk).find(params[:id])
    

    #responde_to sirve para manejar los formatos HTML y PDF
    respond_to do |format|
      #si es HTML, renderiza la vista normal
      format.html
      #si es PDF, genera el PDF usando wicked_pdf
      format.pdf do
        render pdf: "comprobante_venta_#{@sale.id}",
               layout: false,
               page_size: 'A4'
      end
    end
  end
  
  def new
    # SIEMPRE strings
    session["cart"] = { "items" => [], "total_amount" => 0 }
    redirect_to admin_disks_path, notice: "Selecciona discos para agregar a la venta"
  end

  def cart
    @cart_items = session.dig("cart", "items") || []
    @total = session.dig("cart", "total_amount") || 0
  end

  def add_item
    disk = Disk.find(params[:disk_id])
    units = params[:units_sold].to_i
    
    if units <= 0
      redirect_to admin_disks_path, alert: "La cantidad debe ser mayor a 0"
      return
    end
    
    if disk.stock < units
      redirect_to admin_disks_path, alert: "Stock insuficiente para #{disk.name}"
      return
    end
    
    # Inicializar carrito si no existe
    session["cart"] ||= { "items" => [], "total_amount" => 0 }

    Rails.logger.info "🟦 Sesión actual: #{session.to_h}"

    # Agregar item (SOLO STRINGS)
    session["cart"]["items"] << {
      "disk_id" => disk.id,
      "name" => disk.name,
      "units_sold" => units,
      "price" => disk.unit_price.to_f,
      "subtotal" => (disk.unit_price * units).to_f
    }

    # Actualizar total
    session["cart"]["total_amount"] =
      session["cart"]["total_amount"].to_f + (disk.unit_price * units).to_f

    redirect_to admin_disks_path, notice: "#{disk.name} agregado al carrito"
  end

  def remove_item
    index = params[:index].to_i

    if session.dig("cart", "items")
      session["cart"]["items"].delete_at(index)
    end

    # Recalcular total
    session["cart"]["total_amount"] =
      session["cart"]["items"].sum { |i| i["subtotal"] }

    redirect_to cart_admin_sales_path, notice: "Item eliminado del carrito"
  end

  def clear_cart
    session["cart"] = { "items" => [], "total_amount" => 0 }
    redirect_to admin_sales_path, notice: "Carrito vaciado"
  end


  def create
     cart = session["cart"]
     Rails.logger.info "🟩 Creando venta con carrito: #{cart.inspect}"
     Rails.logger.info "🟩 Usuario actual: #{current_user.inspect}"
     
     if cart.nil? || cart["items"].empty?
       redirect_to admin_sales_path, alert: "El carrito está vacío"
       return
     end

    # Crear la venta en memoria (sin guardar aún)
    @sale = Sale.new(
      total_amount: cart['total_amount'],
      deleted: false,
      user_id: current_user.id
    )
    
    # Asociar items en memoria (sin guardar aún)
    cart['items'].each do |item_data|
      disk = Disk.find(item_data['disk_id'])
      @sale.items.build(
        disk: disk,
        description: item_data['name'],
        units_sold: item_data['units_sold'],
        price: item_data['price']
      )
    end
    
    # Ahora guardar todo junto (sale + items)
    if @sale.save
      # Si todo salió bien, limpiar carrito
      session[:cart] = { items: [], total_amount: 0 }  
      redirect_to admin_sale_path(@sale), notice: "Venta creada exitosamente"
    else
      redirect_to cart_admin_sales_path, alert: @sale.errors.full_messages.join(", ")
    end
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
