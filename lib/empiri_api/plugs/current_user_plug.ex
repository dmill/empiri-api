defmodule EmpiriApi.Plugs.CurrentUserPlug do
  alias EmpiriApi.Repo
  alias EmpiriApi.User
  import EmpiriApi.Extensions.ControllerExtensions
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts \\ nil) do
    if Map.get(conn, :user_attrs), do: get_user(conn), else: fail(conn)
  end

  defp get_user(conn) do
    user = Repo.get_by(User, auth_id: conn.user_attrs[:auth_id],
                          auth_provider: conn.user_attrs[:auth_provider])
    if user, do: conn |> Map.merge(%{current_user: user}), else: fail(conn)
  end

  defp fail(conn), do: render_unauthorized(conn) |> halt
end
