class Genre < ApplicationRecord
  has_and_belongs_to_many :disks

  before_validation :normalize_name

  scope :ordered, -> { order(:name) }

  validates :name,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { maximum: 100 }

  private

  def normalize_name
    self.name = name.to_s.strip.squish.downcase.capitalize
  end
end