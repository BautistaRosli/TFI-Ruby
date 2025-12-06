class Disk < ApplicationRecord
  has_many_attached :images
  has_one_attached :cover
  has_and_belongs_to_many :genres

  has_many :items
  has_many :sales, through: :items

  before_create :set_date_ingreso

  validates :name, :author, :description, :format, :unit_price, presence: true
  validates :year, presence: true,
                  numericality: { only_integer: true, greater_than_or_equal_to: 1900, less_than_or_equal_to: Time.current.year }

  # Precio > 0
  validates :unit_price,
            numericality: { greater_than: 0 },
            presence: true

  # Sin caracteres especiales
  NAME_REGEX = /\A[[:alnum:]\s\.\-\/ÁÉÍÓÚáéíóúÑñ]+\z/
  validates :name, :author, :format,
            format: { with: NAME_REGEX, message: "solo letras/números, espacios, . - / y acentos" }

  # evitar caracteres no alfanuméricos
  DESCRIPTION_REGEX = /\A[[:alnum:]\s\.\,\-\!\?\:\;]+\z/
  validates :description,
            format: { with: DESCRIPTION_REGEX, message: "contiene caracteres no permitidos" }

  validate :validate_images_limit
  validate :validate_images_content_type

  MAX_IMAGE_SIZE = 5.megabytes
  ALLOWED_IMAGE_TYPES = %w[image/png image/jpg image/jpeg image/webp image/gif].freeze

  def cover_or_first_image
    cover.attached? ? cover : images.first
  end

  private

  def set_date_ingreso
    self.date_ingreso = Time.current
  end

  def validate_images_limit
    return unless images.attached?
    if images.attachments.size > 10
      errors.add(:images, "no puede tener más de 10 imágenes")
    end
  end

  def validate_images_content_type
    images.each do |img|
      next unless img.blob
      unless ALLOWED_IMAGE_TYPES.include?(img.blob.content_type)
        errors.add(:images, "tiene un formato no permitido")
      end
      if img.blob.byte_size > MAX_IMAGE_SIZE
        errors.add(:images, "cada imagen debe ser menor a #{MAX_IMAGE_SIZE / 1.megabyte}MB")
      end
    end
  end

  def update_stock_on_delete
    update_column(:stock, 0) if has_attribute?(:stock)
  end

  scope :sold_in_active_sales, -> {
    joins(items: :sale)
    .where(sales: { deleted: [ false, nil ] })
    .group(:name)
    .sum("items.units_sold")
    .sort_by { |_k, v| -v }
    .first(10)
  }

  scope :category_sold, -> {
    joins(:items, :sales, :genres)
    .where(sales: { deleted: [ false, nil ] })
    .group("genres.name")
    .sum("items.units_sold")
  }

  scope :format_in_sales, ->(sales) {
    joins(items: :sale)
    .where(sales: { id: sales.ids })
    .group(:format).count
  }

  scope :gender_sold, ->(sales) {
    joins(:genres, items: :sale)
    .where(sales: { id: sales.ids })
    .group("genres.name").count
  }

  scope :ranking_by_gender, ->(gender) {
    joins(:genres, :items)
    .where(genres: { name: gender })
    .group(:name)
    .sum("items.units_sold")
    .sort_by { |_, v| -v }.first(5)
  }
end
