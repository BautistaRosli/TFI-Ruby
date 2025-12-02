class UsedDisk < Disk
  before_validation :set_default_stock
  has_one_attached :audio

  private

  def set_default_stock
    self.stock = 1 if stock.nil?
  end

  # For used disks soft_delete only sets deleted_at; stock should already be nil
  def update_stock_on_delete
    # no-op: keep stock nil
  end
end
