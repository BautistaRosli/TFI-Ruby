module CartManagement
  extend ActiveSupport::Concern

  # Inicializa un carrito vacío en la sesión
  def initialize_cart
    session["cart"] = { "items" => [], "total_amount" => 0 }
  end

  # Retorna los items del carrito actual
  def cart_items
    session.dig("cart", "items") || []
  end

  # Retorna el total del carrito actual
  def cart_total
    session.dig("cart", "total_amount") || 0
  end

  # Retorna el número de items en el carrito
  def cart_items_count
    cart_items.size
  end

  # Verifica si el carrito está vacío
  def cart_empty?
    cart_items.empty?
  end

  # Agrega un disco al carrito
  # Si ya existe, incrementa la cantidad
  def add_to_cart(disk, units)
    # Asegurar que el carrito existe
    session["cart"] ||= { "items" => [], "total_amount" => 0 }
    
    items = session["cart"]["items"]
    
    # Buscar si el disco ya está en el carrito
    existing_item = items.find { |item| item["disk_id"] == disk.id }
    
    if existing_item
      # Actualizar cantidad y subtotal del item existente
      existing_item["units_sold"] += units
      existing_item["subtotal"] = existing_item["units_sold"] * existing_item["price"]
    else
      # Agregar nuevo item al carrito
      items << {
        "disk_id" => disk.id,
        "name" => disk.name,
        "units_sold" => units,
        "price" => disk.unit_price.to_f,
        "subtotal" => (disk.unit_price * units).to_f
      }
    end
    
    # Actualizar el total del carrito
    session["cart"]["total_amount"] = session["cart"]["total_amount"].to_f + (disk.unit_price * units).to_f
  end

  # Elimina un item del carrito por su índice
  def remove_from_cart(index)
    return unless session.dig("cart", "items")
    
    session["cart"]["items"].delete_at(index)
    
    # Recalcular el total
    recalculate_cart_total
  end

  # Limpia completamente el carrito
  def clear_cart
    initialize_cart
  end

  # Recalcula el total del carrito sumando los subtotales
  def recalculate_cart_total
    session["cart"]["total_amount"] = cart_items.sum { |item| item["subtotal"] }
  end

  # Valida que haya stock suficiente para la cantidad solicitada
  # Considera las unidades ya agregadas en el carrito
  def validate_stock(disk, units)
    return { valid: false, message: "La cantidad debe ser mayor a 0" } if units <= 0
    
    # Buscar si el disco ya está en el carrito
    existing_item = cart_items.find { |item| item["disk_id"] == disk.id }
    units_in_cart = existing_item ? existing_item["units_sold"] : 0
    
    # Total de unidades sería las del carrito + las nuevas
    total_units = units_in_cart + units
    
    if disk.stock < total_units
      return { 
        valid: false, 
        message: "Stock insuficiente para #{disk.name}. Disponible: #{disk.stock}, en carrito: #{units_in_cart}, solicitadas: #{units}" 
      }
    end
    
    { valid: true }
  end
end
