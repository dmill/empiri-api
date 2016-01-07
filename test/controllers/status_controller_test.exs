defmodule EmpiriApi.StatusControllerTest do
  use EmpiriApi.ConnCase

  test "without an Authorization header" do
    connection = conn |> put_req_header("content-type", "application/json")
    conn = get connection, status_path(connection, :index)
    assert json_response(conn, 401)["error"] == "unauthorized"
  end

  test "with an invalid Authorization header" do
    connection = conn |> put_req_header("authorization", "Bearer bullshit") |> put_req_header("content-type", "application/json")
    conn = get connection, status_path(connection, :index)

    assert json_response(conn, 401)["error"] == "unauthorized"
  end

  test "with a valid Authorization header" do
    connection = conn |> put_req_header("authorization", "Bearer #{generate_auth_token}") |> put_req_header("content-type", "application/json")
    conn = get connection, status_path(connection, :index)

    assert json_response(conn, 200)["status"] == "available"
  end
end