class Sale < ApplicationRecord
  #Relacion con items de venta, 
  #depends indica que si se borra una venta, se borran sus items asociados, como el borrado es lógico, no pongo el destroy 
  has_many :items

  # Callbacks
  before_create :validate_and_decrease_stock
  after_update :return_stock, if: :saved_change_to_deleted?

  # Validations
  validates :datetime, presence: true
  validates :total_amount, numericality: { greater_than_or_equal_to: 0 }

  # relaciones (a implementar)
  # belongs_to :employee
  # belongs_to :customer
  
  private
  
  def validate_and_decrease_stock
    items.each do |item|
      disk = item.disk
      
      # Validar que el disco existe
      unless disk
        errors.add(:base, "El item '#{item.description}' no tiene un disco asociado")
        throw :abort
      end
      
      # Validar que el disco tiene el atributo stock
      unless disk.has_attribute?(:stock)
        errors.add(:base, "El disco '#{disk.name}' no tiene stock configurado")
        throw :abort
      end
      
      # Validar que hay suficiente stock
      if disk.stock < item.units_sold
        errors.add(:base, "Stock insuficiente para '#{disk.name}'. Disponible: #{disk.stock}, Solicitado: #{item.units_sold}")
        throw :abort
      end
      
      # Decrementar el stock
      disk.decrement!(:stock, item.units_sold)
    end
  end
  
  def return_stock
    if deleted
      items.each do |item|
        disk = item.disk
        # Si el disco no existe o no tiene atributo stock, se pasa al siguiente item.
        next unless disk && disk.has_attribute?(:stock)

        disk.increment!(:stock, item.units_sold)
      end
    end
  end
end