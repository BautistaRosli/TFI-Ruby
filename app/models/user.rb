class User < ApplicationRecord
  # Devise modules: podés agregar más si querés (ej: :confirmable, :trackable)
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :timeoutable

  has_many :sales

  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :lastname, presence: true, length: { minimum: 2, maximum: 50 }
  validates :is_active, inclusion: { in: [ true, false ] }

  # Definición correcta del enum
  enum :role, { admin: 0, manager: 1, employee: 2 }, default: :employee

  def active_for_authentication?
    super && is_active?
  end

  scope :get_sales, -> {
    joins(:sales)
    .where(sales: { deleted: [ false, nil ] })
    .distinct
  }

  scope :by_name, ->(name) { where("name LIKE ?", "%#{name}%") if name.present? }

  scope :by_lastname, ->(lastname) { where("lastname LIKE ?", "%#{lastname}%") if lastname.present? }

  scope :by_email, ->(email) { where("email LIKE ?", "%#{email}%") if email.present? }

  scope :by_role, ->(role) { where(role: role.downcase) if role.present? }
end
