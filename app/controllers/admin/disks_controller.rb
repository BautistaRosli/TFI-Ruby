class Admin::DisksController < ApplicationController
  include CartManagement
  
  layout 'admin'
  
  def index
    @disks = Disk.where(deleted_at: nil)
                 .where('stock > ?', 0)
                 .order(:name)
                 .page(params[:page])
                 .per(10)
    
    # Info del carrito para mostrar en la vista usando el concern
    @cart_items_count = cart_items_count
    @cart_total = cart_total
  end
end
