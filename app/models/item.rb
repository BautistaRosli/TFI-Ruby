class Item < ApplicationRecord
  # relacion con venta(sale)
  belongs_to :sale

  # Validaciones
  validates :price, numericality: { greater_than: 0 }
  validates :description, presence: true
  validates :units_sold, numericality: { greater_than_or_equal_to: 0 }
  validates :sale_id, presence: true
  # Relacion con producto (a implementar)
  # belongs_to :product
end
