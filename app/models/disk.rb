class Disk < ApplicationRecord
  has_many_attached :images
  has_many :items
  
  has_one_attached :cover

  validates :name, presence: true
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }
  validates :format, inclusion: { in: %w[vinilo CD], allow_nil: true }
  

  validate :must_have_image_on_create, on: :create
  validate :validate_cover_content_type
  validate :validate_images_content_type

  MAX_IMAGE_SIZE = 5.megabytes
  ALLOWED_IMAGE_TYPES = %w[image/png image/jpg image/jpeg image/webp image/gif].freeze

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

  def must_have_image_on_create
    if new_record? && !cover.attached? && !images.attached?
      errors.add(:base, "Debe adjuntar al menos una imagen (portada o imágenes)")
    end
  end

  def validate_cover_content_type
    return unless cover.attached?

    unless ALLOWED_IMAGE_TYPES.include?(cover.blob.content_type)
      errors.add(:cover, "formato no permitido")
    end

    if cover.blob.byte_size > MAX_IMAGE_SIZE
      errors.add(:cover, "debe ser menor a #{MAX_IMAGE_SIZE / 1.megabyte}MB")
    end
  end

  def validate_images_content_type
    images.each do |img|
      next unless img.attached? && img.blob.present?

      unless ALLOWED_IMAGE_TYPES.include?(img.blob.content_type)
        errors.add(:images, "contiene archivos con formato no permitido")
      end

      if img.blob.byte_size > MAX_IMAGE_SIZE
        errors.add(:images, "cada imagen debe ser menor a #{MAX_IMAGE_SIZE / 1.megabyte}MB")
      end
    end
  end

  def update_stock_on_delete
    update_column(:stock, 0) if has_attribute?(:stock)
  end
end
