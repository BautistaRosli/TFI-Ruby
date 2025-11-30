class Admin::DisksController < ApplicationController
  layout 'admin'
  before_action :set_disk, only: %i[show edit update destroy change_stock]

  ALLOWED_TYPES = %w[NewDisk UsedDisk].freeze

  def index
    @disks = Disk.order(created_at: :desc).page(params[:page]).per(12)
  end

  def show
  end

  def new
    klass = ALLOWED_TYPES.include?(params[:type]) ? params[:type].constantize : NewDisk
    @disk = klass.new(date_ingreso: Time.current)
  end

  def create
    klass = ALLOWED_TYPES.include?(disk_type_param) ? disk_type_param.constantize : Disk
    @disk = klass.new(disk_params)

    if @disk.save
      attach_optional_files(@disk)
      redirect_to admin_disk_path(@disk), notice: 'Disco creado correctamente'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @disk.update(disk_params)
      attach_optional_files(@disk)
      redirect_to admin_disk_path(@disk), notice: 'Disco actualizado correctamente'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # Borrado lógico: marca deleted_at y ajusta stock por lógica del modelo
  def destroy
    @disk.soft_delete!
    redirect_to admin_disks_path, notice: 'Disco dado de baja (borrado lógico)'
  end

  # Patch para cambiar stock (solo aplicable a NewDisk)
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
    @disk = Disk.find(params[:id])
  end

  def disk_type_param
    params.dig(:disk, :type) || params.dig(:new_disk, :type) || params.dig(:used_disk, :type)
  end

  # Detecta la key de parámetros que corresponde al modelo (disk / new_disk / used_disk)
  def param_key
    key = params.keys.find { |k| k.to_s.match?(/(?:^|_)disk$/) } || 'disk'
    key.to_sym
  end

  # Permite aceptar tanto :disk como :new_disk / :used_disk
  def disk_params
    params.require(param_key).permit(
      :type, :name, :description, :author, :unit_price, :stock,
      :category, :format, :date_ingreso
    )
  end

  def attach_optional_files(disk)
    pk = param_key
    if params.dig(pk, :cover).present?
      disk.cover.attach(params[pk][:cover])
    end

    if params.dig(pk, :images).present?
      disk.images.attach(params[pk][:images])
    end

    # audio only for UsedDisk
    if disk.is_a?(UsedDisk) && params.dig(pk, :audio).present?
      disk.audio.attach(params[pk][:audio])
    end
  end
end