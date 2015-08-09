class ThreadsController < ApplicationController

  def index
    @threads = Publication.limit(5)
    render_threads
  end

  def show
    @thread = Publication.find(params[:id]) rescue nil
    @thread ? render_thread : render_not_found
  end

  private

  def render_threads
    render json: ThreadsRepresenter.new(@threads), status: :ok
  end

  def render_thread
    render json: ThreadRepresenter.new(@thread), status: :ok
  end
end