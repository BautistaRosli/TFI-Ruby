class Admin::DisksController < ApplicationController
  layout 'admin'
  
  def index
    @disks = Disk.where(deleted_at: nil)
                 .where('stock > ?', 0)
                 .order(:name)
                 .page(params[:page])
                 .per(10)
    
    # Info del carrito para mostrar en la vista
    @cart_items_count = session[:cart]["items"]&.size || 0
    
  end
end
