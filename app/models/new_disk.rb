class NewDisk < Disk
  # New disks can have stock (>= 0), no audio
  validates :stock, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # When soft-deleting ensure stock = 0 (inherited behavior already does this)
end
