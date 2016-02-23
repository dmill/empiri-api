defmodule EmpiriApi.ReferenceControllerTest do
  # use EmpiriApi.ConnCase
#
  # alias EmpiriApi.Reference
  # @valid_attrs %{authors: "some content", link: "some content", title: "some content"}
  # @invalid_attrs %{}
#
  # setup %{conn: conn} do
    # {:ok, conn: put_req_header(conn, "accept", "application/json")}
  # end
#
  # test "lists all entries on index", %{conn: conn} do
    # conn = get conn, reference_path(conn, :index)
    # assert json_response(conn, 200)["data"] == []
  # end
#
  # test "shows chosen resource", %{conn: conn} do
    # reference = Repo.insert! %Reference{}
    # conn = get conn, reference_path(conn, :show, reference)
    # assert json_response(conn, 200)["data"] == %{"id" => reference.id,
      # "authors" => reference.authors,
      # "title" => reference.title,
      # "link" => reference.link,
      # "publication_id" => reference.publication_id}
  # end
#
  # test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    # assert_error_sent 404, fn ->
      # get conn, reference_path(conn, :show, -1)
    # end
  # end
#
  # test "creates and renders resource when data is valid", %{conn: conn} do
    # conn = post conn, reference_path(conn, :create), reference: @valid_attrs
    # assert json_response(conn, 201)["data"]["id"]
    # assert Repo.get_by(Reference, @valid_attrs)
  # end
#
  # test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    # conn = post conn, reference_path(conn, :create), reference: @invalid_attrs
    # assert json_response(conn, 422)["errors"] != %{}
  # end
#
  # test "updates and renders chosen resource when data is valid", %{conn: conn} do
    # reference = Repo.insert! %Reference{}
    # conn = put conn, reference_path(conn, :update, reference), reference: @valid_attrs
    # assert json_response(conn, 200)["data"]["id"]
    # assert Repo.get_by(Reference, @valid_attrs)
  # end
#
  # test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    # reference = Repo.insert! %Reference{}
    # conn = put conn, reference_path(conn, :update, reference), reference: @invalid_attrs
    # assert json_response(conn, 422)["errors"] != %{}
  # end
#
  # test "deletes chosen resource", %{conn: conn} do
    # reference = Repo.insert! %Reference{}
    # conn = delete conn, reference_path(conn, :delete, reference)
    # assert response(conn, 204)
    # refute Repo.get(Reference, reference.id)
  # end
end
