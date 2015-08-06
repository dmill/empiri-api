class ExperimentsController < ApplicationController

  def show
    @experiment = Experiment.find(params[:id]) rescue nil
    @experiment ? render_experiment : render_not_found
  end

  private

  def render_experiment
    render json: ExperimentRepresenter.new(@experiment).to_json, status: :ok
  end
end