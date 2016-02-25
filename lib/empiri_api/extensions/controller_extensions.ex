defmodule EmpiriApi.Extensions.ControllerExtensions do
  import Plug.Conn
  import Phoenix.Controller

  def render_not_found(conn) do
    conn |> put_status(:not_found) |> render(EmpiriApi.ErrorView, "404.json")
  end

  def render_unauthorized(conn) do
    conn |> put_status(:unauthorized) |> render(EmpiriApi.ErrorView, "401.json")
  end

  def render_unsupported_media_type(conn) do
    conn |> put_status(:unsupported_media_type) |> render(EmpiriApi.ErrorView, "415.json")
  end
end
