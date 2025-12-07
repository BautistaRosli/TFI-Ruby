class Disk::NewController < ApplicationController
  layout 'disks'
def index
  @disks = NewDisk.all.order(created_at: :desc)

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

  # Filtro por año mínimo (simple, igual que precio)
  @disks = @disks.where("disks.date_ingreso >= ?", "#{params[:min_year]}-01-01") if params[:min_year].present?

  # Filtro por año máximo (simple, igual que precio)
  @disks = @disks.where("disks.date_ingreso <= ?", "#{params[:max_year]}-12-31 23:59:59") if params[:max_year].present?

  @disks = @disks.page(params[:page]).per(8)
  @genres = Genre.order(name: :asc)
  

end

  def show
  @disk = NewDisk.find(params[:id])
  #arranca algoritmo de recomendacion
  #lee cookies
  viewed = cookies.signed[:viewed_disks]
  viewed = viewed ? JSON.parse(viewed) : []

  #agrega disco actual a las cookies
  viewed << @disk.id unless viewed.include?(@disk.id)

  #limita tamaño
  viewed = viewed.last(7)

  #firma las cookies
  cookies.signed[:viewed_disks] = {
    value: viewed.to_json,
    expires: 6.months.from_now
  }

  @recommended_disks = recommended_disks(viewed, @disk)
  end


private

def recommended_disks(viewed_ids, current_disk)
  viewed = Disk.includes(:genres).where(id: viewed_ids)


  #esto agrupo por autor, genero y tipo y cuenta cuantas veces aparece cada uno
  author_freq = viewed.group(:author).count
  genre_freq  = viewed.joins(:genres).group("genres.id").count
  type_freq   = viewed.group(:type).count

  #aca se queda con el total de discos que se vieron, lo pasa a float pq sino ruby llora
  total_views = viewed_ids.size.to_f

  #esto te da la proporcion de cuanto aparece cada autor, genero y tipo sobre el total
  #si viste 10 discos y 5 son de Queen, queen va a tener 0,5
  author_weight = author_freq.transform_values { |v| v / total_views }
  genre_weight  = genre_freq.transform_values  { |v| v / total_views }
  type_weight   = type_freq.transform_values   { |v| v / total_views }

  #me quedo con todos los discos menos el que estoy viendo
  candidates = Disk
    .includes(:genres)
    .where.not(id: current_disk.id)


  #esta parte calcula un score para cada disco 
  scored = candidates.map do |disk|
    score = 0.0


    score += (author_weight[disk.author] || 0) * 0.6

    disk.genres.each do |g|
      score += (genre_weight[g.id] || 0) * 0.3
    end

    score += (type_weight[disk.type] || 0) * 0.1

    [disk, score]
  end

  # ordeno por score descendente
  scored
    .sort_by { |disk, score| -score }
    .first(10)
    .map(&:first)
end
end
