defmodule EmpiriApi.Router do
  use EmpiriApi.Web, :router
  require Logger

  pipeline :api do
    plug :accepts, ["json"]
    plug ContentTypePlug, multipart_regex: ~r/photos/
  end

  scope "/", EmpiriApi do
    pipe_through :api

    get "/", StatusController, :index

    #user show uses the auth token and therefore is not canonically RESTful
    get "/users", UserController, :show

    resources "/users", UserController, only: [:update] do
      resources "photos", UserPhotosController, only: [:create]
    end

    resources "/hypotheses", HypothesisController, except: [:edit, :new]

    resources "/publications", PublicationController, expect: [:edit, :new]
  end
end
