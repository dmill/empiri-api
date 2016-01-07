defmodule EmpiriApi.Plugs.ContentTypePlugTest do

  use ExUnit.Case, async: true
  use EmpiriApi.ConnCase

  test "conn has no content-type header" do
    conn = EmpiriApi.Plugs.ContentTypePlug.call(conn("POST", "/whatever"))
    assert conn.state == :sent
    assert conn.status == 415
  end

  test "conn has a request path that doesn't match the multipart_regex and content-type isn't json" do
    conn = conn("POST", "/whatever")
            |> put_req_header("content-type", "multipart/form-data")
            |> EmpiriApi.Plugs.ContentTypePlug.call(multipart_regex: ~r/photos/)

    assert conn.state == :sent
    assert conn.status == 415
  end

  test "conn has a request path that matches the multipart_regex and content-type isn't multipart" do
    conn = conn("POST", "/photos")
            |> put_req_header("content-type", "application/json")
            |> EmpiriApi.Plugs.ContentTypePlug.call(multipart_regex: ~r/photos/)

    assert conn.state == :sent
    assert conn.status == 415
  end

  test "conn has a request path that matches the multipart_regex and content-type is multipart" do
    connection = conn("POST", "/photos")
                  |> put_req_header("content-type", "multipart/form-data")

    processed_conn = EmpiriApi.Plugs.ContentTypePlug.call(connection, multipart_regex: ~r/photos/)

    refute connection.state == :sent
    assert connection == processed_conn
  end

  test "conn has a request path that doesn't match the multipart_regex and content-type is json" do
    connection = conn("POST", "/whatever")
                  |> put_req_header("content-type", "application/json")

    processed_conn = EmpiriApi.Plugs.ContentTypePlug.call(connection, multipart_regex: ~r/photos/)

    refute connection.state == :sent
    assert connection == processed_conn
  end

  test "content-type is ignored on GET requests" do
    connection = conn("GET", "/whatever")
                  |> put_req_header("content-type", "multipart/form-data")

    processed_conn = EmpiriApi.Plugs.ContentTypePlug.call(connection, multipart_regex: ~r/photos/)

    refute connection.state == :sent
    assert connection == processed_conn
  end
end