defmodule EmpiriApi.PageController do
  use EmpiriApi.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
