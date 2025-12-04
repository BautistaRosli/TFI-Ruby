class Genre < ApplicationRecord
  has_and_belongs_to_many :disks
  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 100 }
end