defmodule EmpiriApi.StatusControllerTest do
  use EmpiriApi.ConnCase

  test "with no content-type header" do
    conn = get conn, status_path(conn, :index)
    assert json_response(conn, 415)["error"] == "Unsupported Media Type"
  end

  test "with an incorrect content-type header" do
    connection = conn |> put_req_header("authorization", "Bearer bullshit") |> put_req_header("content-type", "multipart/form-data")
    conn = get connection, status_path(connection, :index)

    assert json_response(conn, 415)["error"] == "Unsupported Media Type"
  end

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