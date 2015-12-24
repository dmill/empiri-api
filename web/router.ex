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
    resources "/users", UserController, only: [:update]
    resources "/hypotheses", HypothesisController, except: [:edit, :new]
  end
end
