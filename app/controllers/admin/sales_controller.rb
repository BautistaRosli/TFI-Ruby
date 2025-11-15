class Admin::SalesController < ApplicationController
  layout 'admin'
  
  def index
    @sales = Sale.all.order(created_at: :desc)
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
