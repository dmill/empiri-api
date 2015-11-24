defmodule EmpiriApi.Router do
  use EmpiriApi.Web, :router
  require Logger

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Joken.Plug, on_verifying: &EmpiriApi.Router.validate_auth_token/0
  end

  scope "/", EmpiriApi do
    pipe_through :api

    get "/", StatusController, :index
    resources "/users", UserController, only: [:show, :update]
  end

  def validate_auth_token() do
    [client_id: client_id, client_secret: client_secret] = Application.get_env(:empiri_api, Auth0)
    {:ok, secret} = Base.url_decode64(client_secret)

    %Joken.Token{}
    |> Joken.with_json_module(Poison)
    |> Joken.with_signer(Joken.hs256(secret))
    |> Joken.with_validation("aud", &(&1 == client_id))
  end
end
