class Admin::GenresController < ApplicationController
  before_action :authenticate_user!
  layout "admin"

  before_action :set_genre, only: %i[edit update destroy]
  before_action :load_genres, only: %i[index create]

  def index
    @genre = Genre.new
  end

  def create
    @genre = Genre.new(genre_params)

    if @genre.save
      redirect_to admin_genres_path, notice: "Género creado"
    else
      render :index, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @genre.update(genre_params)
      redirect_to admin_genres_path, notice: "Género actualizado"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @genre.destroy
    redirect_to admin_genres_path, notice: "Género eliminado"
  end

  private

  def load_genres
    @genres = Genre.ordered.page(params[:page]).per(20)
  end

  def set_genre
    @genre = Genre.find(params[:id])
  end

  def genre_params
    params.require(:genre).permit(:name)
  end
end
