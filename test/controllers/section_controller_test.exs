defmodule EmpiriApi.SectionControllerTest do
  # use EmpiriApi.ConnCase
#
  # alias EmpiriApi.Section
  # @valid_attrs %{body: "some content", index: 42, title: "some content"}
  # @invalid_attrs %{}
#
  # test "creates and renders resource when data is valid" do
    # conn = post conn, publication_section_path(conn, :create, section: @valid_attrs)
    # assert json_response(conn, 201)["data"]["id"]
    # assert Repo.get_by(Section, @valid_attrs)
  # end
#
  # test "does not create resource and renders errors when data is invalid" do
    # conn = post conn, publication_section_path(conn, :create, section: @invalid_attrs)
    # assert json_response(conn, 422)["errors"] != %{}
  # end
#
  # test "updates and renders chosen resource when data is valid", %{conn: conn} do
    # section = Repo.insert! %Section{}
    # conn = put conn, publication_section_path(conn, :update, section, section: @valid_attrs)
    # assert json_response(conn, 200)["data"]["id"]
    # assert Repo.get_by(Section, @valid_attrs)
  # end
#
  # test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    # section = Repo.insert! %Section{}
    # conn = put conn, publication_section_path(conn, :update, section, section: @invalid_attrs)
    # assert json_response(conn, 422)["errors"] != %{}
  # end
#
  # test "deletes chosen resource", %{conn: conn} do
    # section = Repo.insert! %Section{}
    # conn = delete conn, publication_section_path(conn, :delete, section)
    # assert response(conn, 204)
    # refute Repo.get(Section, section.id)
  # end
end
