class Admin::SalesController < ApplicationController
  layout 'admin'
  
  def index
    @sales = Sale.order(created_at: :asc).page(params[:page]).per(1)
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
  end

  def update
  end

  def destroy
  end
end
