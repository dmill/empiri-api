defmodule EmpiriApi.StatusControllerTest do
  use EmpiriApi.ConnCase

  test "without an Authorization header" do
    conn = get conn, status_path(conn, :index)
    assert json_response(conn, 401)["error"] == "unauthorized"
  end

  test "with an invalid Authorization header" do
    connection = conn |> put_req_header("authorization", "Bearer bullshit")
    conn = get connection, status_path(connection, :index)

    assert json_response(conn, 401)["error"] == "unauthorized"
  end

  test "with a valid Authorization header" do
    connection = conn |> put_req_header("authorization", "Bearer #{generate_auth_token}")
    conn = get connection, status_path(connection, :index)

    assert json_response(conn, 200)["status"] == "available"
  end
end