class Item < ApplicationRecord
  # relacion con venta(sale)
  belongs_to :sale
  # Relacion con disco (disk)
  belongs_to :disk

  # Validaciones
  validates :price, numericality: { greater_than: 0 }
  validates :description, presence: true
  validates :units_sold, numericality: { greater_than_or_equal_to: 0 }
 
  
end
