class Admin::GenresController < ApplicationController
  layout "admin"

  def index
    @genres = Genre.order(:name).page(params[:page]).per(20)
    @genre = Genre.new
  end

  def create
    name = genre_params["name"].downcase.capitalize
    modified_params = genre_params.merge(name: name)
    @genre = Genre.new(modified_params)
    if @genre.save
      redirect_to admin_genres_path, notice: "Género creado"
    else
      @genres = Genre.order(:name).page(params[:page]).per(20)
      render :index, status: :unprocessable_entity
    end
  end

  def edit
    @genre = Genre.find(params[:id])
  end

  def update
    @genre = Genre.find(params[:id])
    if @genre.update(genre_params)
      redirect_to admin_genres_path, notice: "Género actualizado"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @genre = Genre.find(params[:id])
    @genre.destroy
    redirect_to admin_genres_path, notice: "Género eliminado"
  end

  private

  def genre_params
    params.require(:genre).permit(:name)
  end
end
