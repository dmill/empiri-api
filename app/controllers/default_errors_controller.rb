class DefaultErrorsController < ApplicationController
  def unauthenticated
    render json: { error: "authentication failed" }, status: 401
  end

  def not_found
    render json: { error: "unable to locate requested resource" }, status: 404
  end

  def bad_format
    render json: { error: "improperly formatted request" }, status: 400
  end

  def exception
    render json: { error: "internal server error" }, status: 500
  end
end