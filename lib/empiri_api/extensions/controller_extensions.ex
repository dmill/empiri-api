defmodule EmpiriApi.Extensions.ControllerExtensions do
  import Plug.Conn
  import Phoenix.Controller
  import EmpiriApi.Plugs.AuthPlug

  def render_not_found(conn) do
    conn |> put_status(:not_found) |> render(EmpiriApi.ErrorView, "404.json")
  end

  def render_unauthorized(conn) do
    conn |> put_status(:unauthorized) |> render(EmpiriApi.ErrorView, "401.json")
  end

  def render_unsupported_media_type(conn) do
    conn |> put_status(:unsupported_media_type) |> render(EmpiriApi.ErrorView, "415.json")
  end

  def translate_token_claims(conn, _ \\ nil) do
    joken_attrs = conn.assigns[:joken_claims]
    [auth_provider, auth_id] = String.split(joken_attrs["sub"], "|")
    Map.merge(conn, %{user: %{auth_provider: auth_provider, auth_id: auth_id,
                              email: joken_attrs["email"], first_name: joken_attrs["given_name"],
                              last_name: joken_attrs["family_name"], external_photo_url: joken_attrs["picture"]}})
  end


  def authorize_user(conn, resource, params \\ nil) do
    conn = EmpiriApi.Plugs.AuthPlug.call(conn)

    if conn.halted do
      false
    else
      conn |> translate_token_claims |> find_user_auth(resource, params)
    end
  end

  def find_user_auth(conn, resource, params) do
    users_auth_creds = resource.users |> Enum.map(fn(user) ->
                                            %{auth_provider: user.auth_provider, auth_id: user.auth_id} end)

    if Enum.member?(users_auth_creds, %{auth_provider: conn.user[:auth_provider], auth_id: conn.user[:auth_id]}) do
      conn
    else
      false
    end
  end
end
