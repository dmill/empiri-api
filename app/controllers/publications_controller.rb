class PublicationsController < ApplicationController

  def index
    @publications = Publication.limit(5)
    render_publications
  end

  def show
    @publication = Publication.find(params[:id]) rescue nil
    @publication ? render_publication : render_not_found
  end

  private

  def render_publications
    render json: PublicationsRepresenter.new(@publications), status: :ok
  end

  def render_publication
    render json: PublicationRepresenter.new(@publication), status: :ok
  end
end