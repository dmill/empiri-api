defmodule EmpiriApi.Plugs.AuthorizationPlug do
  import Plug.Conn
  import EmpiriApi.Extensions.ControllerExtensions
  alias EmpiriApi.Repo

  def init(opts) do
    opts
  end

  def call(conn, resource_type, opts \\ %{}) do
    load_and_authorize_resource(conn, resource_type, opts)
  end

  defp load_and_authorize_resource(conn, resource_type, opts) do
    resource = Repo.get!(resource_type, conn.params["id"])
    if opts[:ownership_on_associated] do
      conn |> authorize_associated_resource(resource, resource_type, opts)
    else
      conn |> authorize_resource(resource)
    end
  end

  defp authorize_resource(conn, resource) do
    current_user = conn.assigns[:current_user]

    if current_user && resource.user_id == current_user.id do
      conn |> Map.merge(%{resource: resource})
    else
      fail(conn)
    end
  end

  defp authorize_associated_resource(conn, resource, resource_type, opts) do
    current_user = conn.assigns[:current_user]

    if current_user && (assoc = Repo.get_by(opts[:ownership_on_associated], [{:user_id, current_user.id},
                                                                           {resource_atom(resource_type), resource.id}])) do
      check_admin_status(conn, resource, assoc, opts)
    else
      fail(conn)
    end
  end

  defp fail(conn), do: render_unauthorized(conn) |> halt

  defp resource_atom(resource_type) do
   string = resource_type
              |> to_string
              |> String.downcase
              |> String.split(".")
              |> List.last

    String.to_atom(string <> "_id")
  end

  defp check_admin_status(conn, resource, association, opts) do
    if opts[:admin] && !association.admin do
      fail(conn)
    else
      conn |> Map.merge(%{resource: resource})
    end
  end
end
