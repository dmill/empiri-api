defmodule EmpiriApi.UserControllerTest do
  use EmpiriApi.ConnCase

  setup do
    conn = conn() |> put_req_header("accept", "application/json")
    {:ok, conn: conn}
  end
end