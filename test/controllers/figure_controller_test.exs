defmodule EmpiriApi.FigureControllerTest do
  # use EmpiriApi.ConnCase
#
  # alias EmpiriApi.Figure
  # @valid_attrs %{caption: "some content", position: 42}
  # @invalid_attrs %{}
#
  # setup %{conn: conn} do
    # {:ok, conn: put_req_header(conn, "accept", "application/json")}
  # end
#
  # test "lists all entries on index", %{conn: conn} do
    # conn = get conn, figure_path(conn, :index)
    # assert json_response(conn, 200)["data"] == []
  # end
#
  # test "shows chosen resource", %{conn: conn} do
    # figure = Repo.insert! %Figure{}
    # conn = get conn, figure_path(conn, :show, figure)
    # assert json_response(conn, 200)["data"] == %{"id" => figure.id,
      # "caption" => figure.caption,
      # "position" => figure.position,
      # "section_id" => figure.section_id}
  # end
#
  # test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    # assert_error_sent 404, fn ->
      # get conn, figure_path(conn, :show, -1)
    # end
  # end
#
  # test "creates and renders resource when data is valid", %{conn: conn} do
    # conn = post conn, figure_path(conn, :create), figure: @valid_attrs
    # assert json_response(conn, 201)["data"]["id"]
    # assert Repo.get_by(Figure, @valid_attrs)
  # end
#
  # test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    # conn = post conn, figure_path(conn, :create), figure: @invalid_attrs
    # assert json_response(conn, 422)["errors"] != %{}
  # end
#
  # test "updates and renders chosen resource when data is valid", %{conn: conn} do
    # figure = Repo.insert! %Figure{}
    # conn = put conn, figure_path(conn, :update, figure), figure: @valid_attrs
    # assert json_response(conn, 200)["data"]["id"]
    # assert Repo.get_by(Figure, @valid_attrs)
  # end
#
  # test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    # figure = Repo.insert! %Figure{}
    # conn = put conn, figure_path(conn, :update, figure), figure: @invalid_attrs
    # assert json_response(conn, 422)["errors"] != %{}
  # end
#
  # test "deletes chosen resource", %{conn: conn} do
    # figure = Repo.insert! %Figure{}
    # conn = delete conn, figure_path(conn, :delete, figure)
    # assert response(conn, 204)
    # refute Repo.get(Figure, figure.id)
  # end
end
