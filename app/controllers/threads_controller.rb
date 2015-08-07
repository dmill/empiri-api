class ThreadsController < ApplicationController

  def index
  end

  def show
    @thread = Publication.find(params[:id]) rescue nil
    @thread ? render_thread : render_not_found
  end

  private

  def render_thread
    render json: ThreadRepresenter.new(@thread), status: :ok
  end
end