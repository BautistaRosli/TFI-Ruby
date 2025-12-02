class NewDisk < Disk
  validates :stock, presence: true
  validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_blank: true

  validate :audio_must_be_absent_for_new

  private

  def audio_must_be_absent_for_new
    if respond_to?(:audio) && audio.attached?
      errors.add(:audio, "no está permitido para discos nuevos")
    end
  end
end
