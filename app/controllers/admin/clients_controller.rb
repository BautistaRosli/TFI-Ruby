class Admin::ClientsController < ApplicationController
  before_action :authenticate_user!
  def search_by_document
    @client = Client.find_by(document_number: params[:number])

    if @client
      render json: {
        found: true,
        name: @client.name,
        lastname: @client.lastname,
        email: @client.email
      }
    else
      render json: { found: false }
    end
  end
end
