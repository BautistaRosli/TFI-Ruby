class Admin::DisksController < ApplicationController
  include CartManagement

  layout 'admin'
  before_action :set_disk, only: %i[show edit update destroy change_stock]

  ALLOWED_TYPES = %w[NewDisk UsedDisk].freeze

  # index: por defecto muestra discos con stock > 0 ordenados por nombre (admin view),
  # si se pasa ?view=recent muestra por creación (desc) con paginado diferente.
  def index
    @disks = Disk.with_attached_cover.with_attached_images.where(deleted_at: nil)
               .order(:name).page(params[:page]).per(10)

    # Colección separada para la sección "Seleccionar Discos para la Venta"
    @sales_disks = Disk.with_attached_cover.with_attached_images.where(deleted_at: nil)
                     .where('stock > 0').order(:name).page(params[:sales_page]).per(12)

    # Info del carrito para la vista (provista por el concern)
    @cart_items_count = cart_items_count
    @cart_total = cart_total
  end

  def show; end

  def new
    klass = ALLOWED_TYPES.include?(params[:type]) ? params[:type].constantize : NewDisk
    @disk = klass.new(date_ingreso: Time.current)
  end

  def create
    klass = ALLOWED_TYPES.include?(disk_type_param) ? disk_type_param.constantize : Disk
    @disk = klass.new(disk_params)

    # attach BEFORE save so model validations can check attachments
    attach_optional_files(@disk)

    if @disk.save
      redirect_to admin_disk_path(@disk), notice: 'Disco creado correctamente'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @disk.update(disk_params)
      attach_optional_files(@disk) # permitir agregar/actualizar attachments
      redirect_to admin_disk_path(@disk), notice: 'Disco actualizado correctamente'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # borrado lógico
  def destroy
    @disk.soft_delete! if @disk.respond_to?(:soft_delete!)
    redirect_to admin_disks_path, notice: 'Disco dado de baja (borrado lógico)'
  end

  # cambiar stock (solo NewDisk)
  def change_stock
    unless @disk.is_a?(NewDisk)
      redirect_to admin_disk_path(@disk), alert: 'Solo se puede cambiar stock de discos nuevos' and return
    end

    new_stock = params.require(:disk).permit(:stock)[:stock]
    if @disk.update(stock: new_stock)
      redirect_to admin_disk_path(@disk), notice: 'Stock actualizado'
    else
      redirect_to admin_disk_path(@disk), alert: 'No se pudo actualizar el stock'
    end
  end

  private

  def set_disk
    @disk = Disk.with_attached_cover.with_attached_images.find(params[:id])
  end

  # Detectamos el tipo incluso si los params vienen como :new_disk / :used_disk
  def disk_type_param
    params.dig(:disk, :type) || params.dig(:new_disk, :type) || params.dig(:used_disk, :type)
  end

  # Encuentra la key correcta (disk, new_disk, used_disk) para strong params/attachments
  def param_key
    key = params.keys.find { |k| k.to_s.match?(/(?:^|_)disk$/) } || 'disk'
    key.to_sym
  end

  def disk_params
    params.require(param_key).permit(
      :type, :name, :description, :author, :unit_price, :stock,
      :category, :format, :date_ingreso,
      :cover, :audio, images: []
    )
  end

  def attach_optional_files(disk)
    pk = param_key
    return unless params[pk].present?

    if params.dig(pk, :cover).present?
      disk.cover.attach(params[pk][:cover])
    end

    if params.dig(pk, :images).present?
      imgs = Array(params[pk][:images]).reject(&:blank?)
      disk.images.attach(imgs) if imgs.any?
    end

    if disk.is_a?(UsedDisk) && params.dig(pk, :audio).present?
      disk.audio.attach(params[pk][:audio])
    end
  end
end