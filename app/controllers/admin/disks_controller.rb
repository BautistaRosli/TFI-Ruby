class Admin::DisksController < ApplicationController
  layout "admin"
  before_action :authenticate_user!
  before_action :set_disk, only: %i[
    show edit update destroy
    set_cover images add_image remove_image
    soft_delete
  ]

  def index
    @new_disks = NewDisk.order(stock: :desc, created_at: :desc)
                        .page(params[:new_page] || params[:page])
                        .per(6)

    @used_disks = UsedDisk.order(stock: :desc, created_at: :desc)
                          .page(params[:used_page] || params[:page])
                          .per(6)
  end

  def show; end

  def new
    @disk = (params[:type] == "UsedDisk" ? UsedDisk : NewDisk).new
  end

  def create
    klass = type_from_params == "UsedDisk" ? UsedDisk : NewDisk
    @disk = klass.new(disk_params(:create))
    attach_audio(@disk)

    if @disk.save
      redirect_to images_admin_disk_path(@disk), notice: "Disco creado. Ahora podés cargar imágenes."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    @disk.assign_attributes(disk_params(:update))
    attach_audio(@disk)
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
    attachment_id = params[:cover_image_id].to_i
    img = @disk.images.attachments.find { |a| a.id == attachment_id }
    unless img
      redirect_to admin_disk_path(@disk), alert: "Imagen no encontrada" and return
    end
    @disk.cover.attach(img.blob)
    redirect_to admin_disk_path(@disk), notice: "Portada actualizada"
  end

  def images; end

  def add_image
    file = params[:image]
    if file.blank?
      redirect_to images_admin_disk_path(@disk), alert: "Seleccioná un archivo de imagen" and return
    end
    current_count = @disk.images.attachments.size
    if current_count >= 10
      redirect_to images_admin_disk_path(@disk), alert: "Máximo 10 imágenes" and return
    end
    @disk.images.attach(file)
    @disk.cover.attach(@disk.images.first.blob) unless @disk.cover.attached?
    redirect_to images_admin_disk_path(@disk), notice: "Imagen subida"
  end

  def remove_image
    attachment_id = params[:id].to_i
    img = @disk.images.attachments.find { |a| a.id == attachment_id }
    unless img
      redirect_to images_admin_disk_path(@disk), alert: "Imagen no encontrada" and return
    end
    was_cover = (@disk.cover&.attached? && @disk.cover.blob_id == img.blob_id)
    img.purge
    if was_cover
      first = @disk.images.first
      first ? @disk.cover.attach(first.blob) : (@disk.cover.purge if @disk.cover&.attached?)
    end
    redirect_to images_admin_disk_path(@disk), notice: "Imagen eliminada"
  end

  def soft_delete
    @disk.transaction do
      @disk.update!(deleted_at: Time.current)
      @disk.update!(stock: 0) if @disk.has_attribute?(:stock)
    end
    redirect_to admin_disk_path(@disk), notice: "Disco dado de baja (borrado lógico)"
  rescue => e
    redirect_to admin_disk_path(@disk), alert: "No se pudo dar de baja: #{e.message}"
  end

  private

  def set_disk
    @disk = Disk.with_attached_cover.with_attached_images.find(params[:id])
  end

  def param_key
    %i[disk new_disk used_disk].find { |k| params.key?(k) } || :disk
  end

  def type_from_params
    params.dig(param_key, :type)
  end

  def disk_params(context = :create)
    permitted = [
      :name, :author, :description, :unit_price, :stock,
      :format, :date_ingreso, :year,
      genre_ids: []
    ]
    permitted << :type if context == :create
    if (context == :create && type_from_params == "UsedDisk") || (context == :update && @disk.is_a?(UsedDisk))
      permitted << :audio
    end
    params.require(param_key).permit(*permitted)
  end

  def attach_audio(disk)
    return unless disk.is_a?(UsedDisk)
    file = params.dig(param_key, :audio)
    return if file.blank?
    disk.audio.attach(file)
  end
end
