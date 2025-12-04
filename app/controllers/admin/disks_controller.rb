class Admin::DisksController < ApplicationController
  layout 'admin'
  before_action :set_disk, only: %i[
    show edit update destroy
    set_cover images add_image remove_image
  ]

  def index
    @new_disks  = Disk.with_attached_cover.with_attached_images.where(type: 'NewDisk').order(:name).page(params[:new_page]).per(10)
    @used_disks = Disk.with_attached_cover.with_attached_images.where(type: 'UsedDisk').order(:name).page(params[:used_page]).per(10)
  end

  def show; end

  def new
    @disk = (params[:type] == 'UsedDisk' ? UsedDisk : NewDisk).new
  end

  def create
    klass = type_from_params == 'UsedDisk' ? UsedDisk : NewDisk
    @disk = klass.new(disk_params(:create))

    if @disk.save
      redirect_to images_admin_disk_path(@disk), notice: "Disco creado. Ahora podés cargar imágenes."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    # no permitir cambiar :type en update
    if @disk.update(disk_params(:update))
      redirect_to admin_disk_path(@disk), notice: "Disco actualizado"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @disk.destroy
    redirect_to admin_disks_path, notice: "Disco eliminado"
  end

  # Portada desde show: adjunta el blob elegido a cover
  def set_cover
    attachment_id = params[:cover_image_id].to_i
    img = @disk.images.attachments.find { |a| a.id == attachment_id }
    unless img
      redirect_to admin_disk_path(@disk), alert: "Imagen no encontrada" and return
    end
    @disk.cover.attach(img.blob)
    redirect_to admin_disk_path(@disk), notice: "Portada actualizada"
  end

  # Gestión de imágenes
  def images
    # Vista para subir y previsualizar (sin tocar otros campos del disco)
  end

  def add_image
    file = params[:image]
    if file.blank?
      redirect_to images_admin_disk_path(@disk), alert: "Seleccioná un archivo de imagen" and return
    end

    # Límite 10
    current_count = @disk.images.attachments.size
    if current_count >= 10
      redirect_to images_admin_disk_path(@disk), alert: "Máximo 10 imágenes" and return
    end

    @disk.images.attach(file)

    # Si no hay portada, usar la primera imagen
    @disk.cover.attach(@disk.images.first.blob) unless @disk.cover.attached?

    redirect_to images_admin_disk_path(@disk), notice: "Imagen subida"
  end

  def remove_image
    attachment_id = params[:id].to_i
    img = @disk.images.attachments.find { |a| a.id == attachment_id }
    unless img
      redirect_to images_admin_disk_path(@disk), alert: "Imagen no encontrada" and return
    end

    # Si era la portada, despegarla y volver a setear portada con la primera restante
    was_cover = (@disk.cover&.attached? && @disk.cover.blob_id == img.blob_id)
    img.purge

    if was_cover
      first = @disk.images.first
      if first
        @disk.cover.attach(first.blob)
      else
        @disk.cover.purge if @disk.cover&.attached?
      end
    end

    redirect_to images_admin_disk_path(@disk), notice: "Imagen eliminada"
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
      :format, :date_ingreso,
      genre_ids: []
    ]
    permitted << :type if context == :create
    params.require(param_key).permit(*permitted)
  end
end