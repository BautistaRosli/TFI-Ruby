class Disk::UsedController < ApplicationController
  layout 'disks'

def index
  @disks = UsedDisk.all.order(created_at: :desc)

  # Filtro por nombre
  @disks = @disks.where("disks.name LIKE ?", "%#{params[:name]}%") if params[:name].present?

  # Filtro por autor
  @disks = @disks.where("disks.author LIKE ?", "%#{params[:author]}%") if params[:author].present?

  # Filtro por género
  if params[:genre_id].present?
    @disks = @disks.joins(:genres).where(genres: { id: params[:genre_id] }).distinct
  end

  # Filtro por precio mínimo
  @disks = @disks.where("disks.unit_price >= ?", params[:min_price]) if params[:min_price].present?

  # Filtro por precio máximo
  @disks = @disks.where("disks.unit_price <= ?", params[:max_price]) if params[:max_price].present?

  @disks = @disks.page(params[:page]).per(8)
  @genres = Genre.order(name: :asc)
end

  def show
  @disk = UsedDisk.find(params[:id])
  #arranca algoritmo de recomendacion
  #lee cookies
  viewed = cookies.signed[:viewed_disks]
  viewed = viewed ? JSON.parse(viewed) : []

  #agrega disco actual a las cookies
  viewed << @disk.id unless viewed.include?(@disk.id)

  #limita tamaño
  viewed = viewed.last(20)

  #firma las cookies
  cookies.signed[:viewed_disks] = {
    value: viewed.to_json,
    expires: 6.months.from_now
  }

  @recommended_disks = recommended_disks(viewed, @disk)
  end


private

def recommended_disks(viewed_ids, current_disk)
  recent_ids = viewed_ids.last(5) - [current_disk.id]

  return [] if recent_ids.empty?

  recent = Disk.where(id: recent_ids)

  # obtener géneros predominantes
  genre_ids = recent.joins(:genres).pluck("genres.id")

  Disk.joins(:genres)
      .where(genres: { id: genre_ids })
      .where.not(id: viewed_ids) # evitar repetidos
      .where.not(id: current_disk.id)
      .distinct
      .limit(10)
end
end
