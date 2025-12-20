class UsedDisk < Disk
  before_validation :set_default_stock
  has_one_attached :audio

  MAX_AUDIO_SIZE = 10.megabytes
  ALLOWED_AUDIO_TYPES = %w[audio/mpeg audio/mp3 audio/wav audio/ogg audio/flac].freeze

  validate :validate_audio_content_type_and_size

  def attach_audio(file)
    return if file.blank?

    audio.attach(file)
  end

  private

  def validate_audio_content_type_and_size
    return unless audio.attached? && audio.blob.present?

    unless ALLOWED_AUDIO_TYPES.include?(audio.blob.content_type)
      errors.add(:audio, "formato no permitido")
    end

    if audio.blob.byte_size > MAX_AUDIO_SIZE
      errors.add(:audio, "debe ser menor a #{MAX_AUDIO_SIZE / 1.megabyte}MB")
    end
  end

  def set_default_stock
    self.stock = 1 if stock.nil?
  end

  # def update_stock_on_delete
  # end

    scope :ordered, -> {
    order(created_at: :desc)
  }

  scope :by_name, ->(name) {
    where("disks.name LIKE ?", "%#{name}%") if name.present?
  }

  scope :by_author, ->(author) {
    where("disks.author LIKE ?", "%#{author}%") if author.present?
  }

  scope :by_genre, ->(genre_id) {
    joins(:genres).where(genres: { id: genre_id }).distinct if genre_id.present?
  }

  scope :min_price, ->(price) {
    where("disks.unit_price >= ?", price) if price.present?
  }

  scope :max_price, ->(price) {
    where("disks.unit_price <= ?", price) if price.present?
  }

  scope :min_year, ->(year) {
    where("disks.year >= ?", year) if year.present?
  }

  scope :max_year, ->(year) {
    where("disks.year <= ?", year) if year.present?
  }
end

