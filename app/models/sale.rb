class Sale < ApplicationRecord
  #Relacion con items de venta, 
  #depends indica que si se borra una venta, se borran sus items asociados 
  has_many :items, dependent: :destroy

  # Validations
  validates :datetime, presence: true
  validates :total_amount, numericality: { greater_than_or_equal_to: 0 }

  # relaciones (a implementar)
  # belongs_to :employee
  # belongs_to :customer
end
