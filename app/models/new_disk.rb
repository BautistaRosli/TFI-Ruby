class NewDisk < Disk
  # Stock obligatorio y entero >= 0
  validates :stock, presence: true
  validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validate :audio_must_be_absent_for_new

  private

  def audio_must_be_absent_for_new
    if respond_to?(:audio) && audio.attached?
      errors.add(:audio, "no está permitido para discos nuevos")
    end
  end

  # scopes para graficos
  scope :low_stock, -> {
    where("stock <= ?", 5)
    .where("stock > ?", 0)
    .order(:stock)
    .limit(10)
    .pluck(:name, :stock)
  }

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
