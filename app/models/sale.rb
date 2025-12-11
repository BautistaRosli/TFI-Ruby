class Sale < ApplicationRecord
  # Relacion con items de venta,
  # depends indica que si se borra una venta, se borran sus items asociados, como el borrado es lógico, no pongo el destroy
  has_many :items

  has_many :disks, through: :items

  # Callbacks
  before_create :validate_and_decrease_stock
  after_update :return_stock, if: :saved_change_to_deleted?

  # Validaciones
  validates :total_amount, numericality: { greater_than_or_equal_to: 0 }

  # relaciones (a implementar)
  belongs_to :user
  belongs_to :customer, class_name: "Client", optional: true

  # Scopes
  scope :active, -> { where(deleted: false) }
  scope :deleted_sales, -> { where(deleted: true) }
  scope :by_sale_id, ->(id) { where(id: id) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_customer, ->(customer_id) { where(customer_id: customer_id) }
  scope :min_amount, ->(amount) { where("total_amount >= ?", amount) }
  scope :max_amount, ->(amount) { where("total_amount <= ?", amount) }
  scope :date_range, ->(from_date, to_date) { where("DATE(datetime) BETWEEN ? AND ?", from_date, to_date) }
  scope :recent_first, -> { order(created_at: :desc) }

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

  # Scope para uso en gráficos

  scope :users_by_account_of_sales, -> {
  joins(:user)
  .where(deleted: [ false, nil ])
  .group(" users.id || ' ' || users.name || ' ' || users.lastname")
  .count
  .sort_by { |_k, v| -v }
  .first(10)
  }

  scope :revenue_by_week, -> {
    where(deleted: false).
    group_by_week(:created_at).
    sum(:total_amount)
  }

  scope :sales_from_cd, -> {
    joins(:disks)
    .where(disks: { format: "CD" })
    .count
  }

  scope :sales_from_vinilo, -> {
    joins(:disks)
    .where(disks: { format: "vinilo" })
    .count
  }

  scope :average_sale_value_by_day, -> {
  where(deleted: [ false, nil ])
  .group_by_day(:created_at)
  .average(:total_amount)
  }

  scope :top_customer, -> {
    joins(:customer)
    .where(deleted: [ false, nil ])
    .group("clients.document_number || ' ' || clients.name || ' ' || clients.lastname")
    .sum(:total_amount)
    .sort_by { |_k, v| -v }
    .first(5)
  }

  scope :sales_by_hour, -> {
    where(deleted: [ false, nil ])
    .group_by_hour_of_day(:created_at, format: "%H:00")
    .count
  }

  scope :sales_by_employee, ->(employee_id) {
    where(user_id: employee_id, deleted: [ false, nil ])
  }

  scope :sales_by_customer, ->(customer_id) {
    where(customer_id: customer_id, deleted: [ false, nil ])
  }

  scope :sales_by_gender, ->(genero) {
    joins(items: { disk: :genres })
    .where(genres: { name: genero })
    .where(sales: { deleted: [ false, nil ] })
  }

  scope :anonymous_sales, ->(anonymous_id) {
    where(customer_id: anonymous_id, deleted: [ false, nil ])
  }

  scope :deleted_sales, -> {
    where(deleted: true)
  }
end
