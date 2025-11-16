class UsedDisk < Disk
  # Used disks are unique items: no stock, optional audio
  validate :stock_must_be_nil
  has_one_attached :audio

  private

  def stock_must_be_nil
    errors.add(:stock, "must be blank for used disks") if stock.present?
  end

  # For used disks soft_delete only sets deleted_at; stock should already be nil
  def update_stock_on_delete
    # no-op: keep stock nil
  end
end
