class Admin::DisksController < ApplicationController
  layout "admin"
  before_action :authenticate_user!
  before_action :set_disk, only: %i[
    show edit update destroy
    set_cover images add_image remove_image
    soft_delete
  ]

  def index
    @new_disks = NewDisk.with_media.admin_ordered
                        .page(params[:new_page] || params[:page])
                        .per(6)

    @used_disks = UsedDisk.with_media.admin_ordered
                          .page(params[:used_page] || params[:page])
                          .per(6)
  end

  def show; end

  def new
    @disk = Disk.new(type: type_from_params)
  end

  def create
    @disk = Disk.new(disk_params(:create))
    @disk.attach_audio(params.dig(:disk, :audio)) if @disk.respond_to?(:attach_audio)

    if @disk.save
      redirect_to images_admin_disk_path(@disk), notice: "Disco creado. Ahora podés cargar imágenes."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    @disk.assign_attributes(disk_params(:update))
    @disk.attach_audio(params.dig(:disk, :audio)) if @disk.respond_to?(:attach_audio)

    if @disk.save
      redirect_to admin_disk_path(@disk), notice: "Disco actualizado"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @disk.destroy
    redirect_to admin_disks_path, notice: "Disco eliminado"
  end

  def set_cover
    @disk.set_cover_from_attachment!(params[:cover_image_id].to_i)
    redirect_to admin_disk_path(@disk), notice: "Portada actualizada"
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_disk_path(@disk), alert: "Imagen no encontrada"
  end

  def images; end

  def add_image
    @disk.add_image!(params[:image])
    redirect_to images_admin_disk_path(@disk), notice: "Imagen subida"
  rescue ArgumentError
    redirect_to images_admin_disk_path(@disk), alert: "Seleccioná un archivo de imagen"
  rescue ActiveRecord::RecordInvalid
    redirect_to images_admin_disk_path(@disk), alert: @disk.errors.full_messages.to_sentence
  end

  def remove_image
    @disk.remove_image!(params[:id].to_i)
    redirect_to images_admin_disk_path(@disk), notice: "Imagen eliminada"
  rescue ActiveRecord::RecordNotFound
    redirect_to images_admin_disk_path(@disk), alert: "Imagen no encontrada"
  end

  def soft_delete
    @disk.soft_delete!
    redirect_to admin_disk_path(@disk), notice: "Disco dado de baja (borrado lógico)"
  rescue => e
    redirect_to admin_disk_path(@disk), alert: "No se pudo dar de baja: #{e.message}"
  end

  private

  def set_disk
    @disk = Disk.with_media.find(params[:id])
  end

  def type_from_params
    raw = params.dig(:disk, :type) || params[:type]
    raw = raw.to_s
    raw = "NewDisk" if raw.blank?

    allowed = %w[NewDisk UsedDisk]
    allowed.include?(raw) ? raw : "NewDisk"
  end

  def disk_params(context = :create)
    permitted = [
      :name, :author, :description, :unit_price, :stock,
      :format, :date_ingreso, :year,
      genre_ids: []
    ]
    permitted << :type if context == :create

    p = params.require(:disk).permit(*permitted)
    p[:type] = type_from_params if context == :create
    p
  end
end
