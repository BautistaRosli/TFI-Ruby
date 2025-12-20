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

  validates :unit_price, numericality: { greater_than: 0 }

  ALLOWED_TEXT_REGEX = /\A[\p{L}\p{N}\s\.\,\-\/&'!\?:;\(\)#]+\z/u

  validates :name, :author, :format,
            format: { with: ALLOWED_TEXT_REGEX,
                      message: "solo letras/números, espacios y . , - / & ' ! ? : ; ( ) #" }
  validates :description,
            format: { with: ALLOWED_TEXT_REGEX,
                      message: "contiene caracteres no permitidos (permitidos: letras con acentos, números y . , - / & ' ! ? : ; ( ) #)" }

  validate :validate_images_limit
  validate :validate_images_content_type

  MAX_IMAGE_SIZE = 5.megabytes
  MAX_IMAGES = 10
  ALLOWED_IMAGE_TYPES = %w[image/png image/jpg image/jpeg image/webp image/gif].freeze

  scope :kept, -> { where(deleted_at: nil) }
  scope :discarded, -> { where.not(deleted_at: nil) }
  scope :admin_ordered, -> { order(stock: :desc, created_at: :desc) }
  scope :with_media, -> { with_attached_cover.with_attached_images }

  STI_TYPES = %w[NewDisk UsedDisk].freeze
  validates :type, inclusion: { in: STI_TYPES }, allow_nil: true

  def cover_or_first_image
    cover.attached? ? cover : images.first
  end


  def set_cover_from_attachment!(attachment_id)
    attachment = images.attachments.find(attachment_id)
    cover.attach(attachment.blob)
  end

  def add_image!(file)
    raise ArgumentError, "image file is required" if file.blank?

    if images.attachments.size >= MAX_IMAGES
      errors.add(:images, "no puede tener más de #{MAX_IMAGES} imágenes")
      raise ActiveRecord::RecordInvalid, self
    end

    images.attach(file)
    attachment = images.attachments.last

    unless attachment&.blob
      errors.add(:images, "no se pudo procesar la imagen")
      raise ActiveRecord::RecordInvalid, self
    end

    unless ALLOWED_IMAGE_TYPES.include?(attachment.blob.content_type)
      attachment.purge
      errors.add(:images, "tiene un formato no permitido")
      raise ActiveRecord::RecordInvalid, self
    end

    if attachment.blob.byte_size > MAX_IMAGE_SIZE
      attachment.purge
      errors.add(:images, "cada imagen debe ser menor a #{MAX_IMAGE_SIZE / 1.megabyte}MB")
      raise ActiveRecord::RecordInvalid, self
    end

    cover.attach(images.first.blob) unless cover.attached?
    attachment
  end

  def remove_image!(attachment_id)
    attachment = images.attachments.find(attachment_id)
    was_cover = cover.attached? && cover.blob_id == attachment.blob_id

    transaction do
      attachment.purge

      return unless was_cover

      # Asegura que no usemos una colección cacheada
      images.attachments.reload

      next_attachment = images.attachments.order(:created_at).first

      if next_attachment.present?
        cover.attach(next_attachment.blob)
      else
        cover.purge if cover.attached?
      end
    end
  end

  def soft_delete!
    transaction do
      update!(deleted_at: Time.current)
      update!(stock: 0) if has_attribute?(:stock)
    end
  end

  scope :sold_in_active_sales, -> {
    joins(items: :sale)
      .where(sales: { deleted: [false, nil] })
      .group(:name)
      .sum("items.units_sold")
      .sort_by { |_k, v| -v }
      .first(10)
  }

  scope :category_sold, -> {
    joins(:items, :sales, :genres)
      .where(sales: { deleted: [false, nil] })
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

  private

  def set_date_ingreso
    self.date_ingreso = Time.current
  end

  def validate_images_limit
    return unless images.attached?
    if images.attachments.size > MAX_IMAGES
      errors.add(:images, "no puede tener más de #{MAX_IMAGES} imágenes")
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
end
