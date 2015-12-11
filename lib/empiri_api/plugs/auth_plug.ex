defmodule EmpiriApi.Plugs.AuthPlug do

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    Joken.Plug.call(conn, { &validate_auth_token/0, &unauthorized/2 })
  end

  defp validate_auth_token() do
    [client_id: client_id, client_secret: client_secret] = Application.get_env(:empiri_api, Auth0)
    {:ok, secret} = Base.url_decode64(client_secret)

    %Joken.Token{}
    |> Joken.with_json_module(Poison)
    |> Joken.with_signer(Joken.hs256(secret))
    |> Joken.with_validation("aud", &(&1 == client_id))
  end

  defp unauthorized(conn, _) do
    {conn, %{error: "unauthorized"}}
  end
end
