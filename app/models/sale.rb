class Sale < ApplicationRecord
  #Relacion con items de venta, 
  #depends indica que si se borra una venta, se borran sus items asociados, como el borrado es lógico, no pongo el destroy 
  has_many :items


 #Trigger para borrar logico de items al borrar logico de venta
  after_update :return_stock, if: :saved_change_to_deleted?
 #saved_change_to_deleted? es un metodo de Active Record que devuelve true si el atributo deleted ha cambiado en la ultima operacion de guardado.


  # Validations
  validates :datetime, presence: true
  validates :total_amount, numericality: { greater_than_or_equal_to: 0 }

  # relaciones (a implementar)
  # belongs_to :employee
  # belongs_to :customer
  private
  def return_stock
    if deleted
      items.each do |item|
        disk = item.disk
        next unless disk && disk.has_attribute?(:stock)

        disk.increment!(:stock, item.units_sold)
      end
    end
  end
end