class User < ApplicationRecord
  # Devise modules: podés agregar más si querés (ej: :confirmable, :trackable)
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true
  validates :lastname, presence: true
  validates :is_active, inclusion: { in: [ true, false ] }

  # Definición correcta del enum
  enum :role, { admin: 0, manager: 1, employee: 2 }, default: :employee
end
