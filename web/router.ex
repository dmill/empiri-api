defmodule EmpiriApi.Router do
  use EmpiriApi.Web, :router
  require Logger

  pipeline :api do
    plug :accepts, ["json"]
    plug Joken.Plug, on_verifying: &EmpiriApi.Router.validate_auth_token/0,
                     on_error: &EmpiriApi.Router.unauthorized/2
  end

  scope "/", EmpiriApi do
    pipe_through :api

    get "/", StatusController, :index

    #user show uses the auth token and therefore is not canonically RESTful
    get "/users", UserController, :show
    resources "/users", UserController, only: [:update]
  end

  def validate_auth_token() do
    [client_id: client_id, client_secret: client_secret] = Application.get_env(:empiri_api, Auth0)
    {:ok, secret} = Base.url_decode64(client_secret)

    %Joken.Token{}
    |> Joken.with_json_module(Poison)
    |> Joken.with_signer(Joken.hs256(secret))
    |> Joken.with_validation("aud", &(&1 == client_id))
  end

  def unauthorized(conn, _) do
    {conn, %{error: "unauthorized"}}
  end
end
