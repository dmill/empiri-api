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

    get "/users/login", UserController, :login

    resources "/users", UserController, only: [:update, :show] do
      resources "photos", UserPhotosController, only: [:create]
    end

    resources "/hypotheses", HypothesisController, except: [:edit, :new]

    resources "/publications", PublicationController, except: [:edit, :new] do

      resources "/authors", AuthorController, only: [:create, :update, :delete]

      resources "/sections", SectionController, only: [:create, :update, :delete] do
        resources "photos", FigurePhotosController, only: [:create]

        resources "figures", FigureController, only: [:create, :update, :delete] do
          put "photos", FigurePhotosController, :update
          patch "photos", FigurePhotosController, :update
        end
      end

      resources "/references", ReferenceController, only: [:create, :update, :delete]

      resources "/reviews", ReviewController, only: [:create, :update, :delete, :index]
    end
  end
end
