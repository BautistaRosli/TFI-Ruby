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

  @disks = @disks.page(params[:page]).per(8)
  @genres = Genre.order(name: :asc)
end

  def show
    @disk = NewDisk.find(params[:id])
  end
end
