class Disk < ApplicationRecord
  # Attach images (needs Active Storage tables)
  has_many_attached :images
  has_one_attached :cover

  has_many :items
  has_many :sales, through: :items

  # Common validations
  validates :name, presence: true
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }
  validates :format, inclusion: { in: %w[vinilo CD], allow_nil: true }

  scope :active, -> { where(deleted_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }

  def soft_delete!
    transaction do
      update!(deleted_at: Time.current)
      update_stock_on_delete
    end
  end

  def deleted?
    deleted_at.present?
  end

  private

  # Hook override by subclasses if needed
  def update_stock_on_delete
    update_column(:stock, 0) if has_attribute?(:stock)
  end

  scope :sold_in_active_sales, -> {
    joins(:sales)
    .where(sales: { deleted: [ false, nil ] })
    .distinct
  }
end
