class UsedDisk < Disk
  before_validation :set_default_stock
  has_one_attached :audio

  MAX_AUDIO_SIZE = 10.megabytes
  ALLOWED_AUDIO_TYPES = %w[audio/mpeg audio/mp3 audio/wav audio/ogg audio/flac].freeze

  validate :validate_audio_content_type_and_size

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

  # def update_stock_on_delete
  # end
end
