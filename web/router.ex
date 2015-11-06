defmodule EmpiriApi.Router do
  use EmpiriApi.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EmpiriApi do
    pipe_through :api

    get "/", StatusController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", EmpiriApi do
  #   pipe_through :api
  # end
end
