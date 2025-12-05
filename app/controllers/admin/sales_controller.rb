class Admin::SalesController < ApplicationController
  include CartManagement
  before_action :authenticate_user!

  # alias al método del concern antes de definir la acción con el mismo nombre
  alias_method :clear_cart_session, :clear_cart

  layout "admin"

  def index
    @sales = Sale.where(deleted: false).order(created_at: :asc).page(params[:page]).per(3)
  end

  def show
    @sale = Sale.includes(items: :disk).find(params[:id])


    # respond_to sirve para manejar los formatos HTML y PDF
    respond_to do |format|
      # si es HTML, renderiza la vista normal
      format.html
      # si es PDF, genera el PDF usando wicked_pdf
      format.pdf do
        render pdf: "comprobante_venta_#{@sale.id}",
               layout: false,
               page_size: "A4"
      end
    end
  end

  def new
    initialize_cart
    redirect_to admin_disks_path(from: "sale"), notice: "Selecciona discos para agregar a la venta"
  end

  def cart
    @cart_items = cart_items
    @total = cart_total
  end

  def add_item
    disk = Disk.find(params[:disk_id])
    units = params[:units_sold].to_i

    # Validar stock usando el concern (ya considera unidades en carrito)
    validation = validate_stock(disk, units)
    unless validation[:valid]
      redirect_to admin_disks_path(from: "sale"), alert: validation[:message]
      return
    end

    # Agregar al carrito usando el concern
    add_to_cart(disk, units)

    redirect_to admin_disks_path(from: "sale"), notice: "#{disk.name} agregado al carrito"
  end

  def remove_item
    index = params[:index].to_i
    remove_from_cart(index)
    redirect_to cart_admin_sales_path, notice: "Item eliminado del carrito"
  end

  def clear_cart
    clear_cart_session
    redirect_to admin_sales_path, notice: "Carrito vaciado"
  end


  def create
     if cart_empty?
       redirect_to admin_sales_path, alert: "El carrito está vacío"
       return
     end

     # Sección del cliente
     @client = nil

     if params[:client_mode] == "existing"
       dni = params[:existing_dni].strip
       @client = Client.find_by(document_number: dni)

       unless @client
         redirect_to cart_admin_sales_path, alert: "Error: No se encontró cliente con DNI #{dni}"
         return
       end

     elsif params[:client_mode] == "new"

       client_params = params.require(:new_client).permit(:name, :lastname, :email, :document_type, :document_number)


       @client = Client.new(client_params)

       unless @client.save
         redirect_to cart_admin_sales_path, alert: "Error al crear cliente: #{@client.errors.full_messages.join(', ')}"
         return
       end
     end

     cart = session["cart"]

    # Crear la venta en memoria (sin guardar aún)
    @sale = Sale.new(
      total_amount: cart["total_amount"],
      deleted: false,
      user_id: current_user.id,
      customer_id: @client.id
    )

    # Asociar items en memoria (sin guardar aún)
    cart["items"].each do |item_data|
      disk = Disk.find(item_data["disk_id"])
      @sale.items.build(
        disk: disk,
        description: item_data["name"],
        units_sold: item_data["units_sold"],
        price: item_data["price"]
      )
    end

    # Ahora guardar todo junto (sale + items)
    if @sale.save
      # Actualizar stock de los discos vendidos
      @sale.items.each do |item|
        disk = item.disk
        if disk.is_a?(NewDisk)
          new_stock = disk.stock.to_i - item.units_sold.to_i
          disk.update!(stock: [new_stock, 0].max)
        else # UsedDisk
          disk.update!(stock: 0)
        end
      end

      # llamar al método del concern (no a la acción)
      clear_cart_session
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
