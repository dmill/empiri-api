defmodule EmpiriApi.StatusController do
  use EmpiriApi.Web, :controller

  plug AuthPlug

  def index(conn, _params) do
    json conn, %{status: "available"}
  end
end