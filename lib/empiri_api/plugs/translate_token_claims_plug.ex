defmodule EmpiriApi.Plugs.TranslateTokenClaimsPlug do
  import Plug.Conn
  import EmpiriApi.Extensions.ControllerExtensions

  def init(opts) do
    opts
  end

  def call(conn, _opts \\ nil) do
    joken_attrs = conn.assigns[:joken_claims]
    if joken_attrs do
      [auth_provider, auth_id] = String.split(joken_attrs["sub"], "|")
      Map.merge(conn, %{user_attrs: %{auth_provider: auth_provider, auth_id: auth_id,
                                      email: joken_attrs["email"], first_name: joken_attrs["given_name"],
                                      last_name: joken_attrs["family_name"], external_photo_url: joken_attrs["picture"]}})
    else
      conn |> render_unauthorized |> halt
    end
  end
end
