defmodule EmpiriApi.UserControllerTest do
  use EmpiriApi.ConnCase

  alias EmpiriApi.User
  @valid_attrs %{email: "some content", first_name: "some content", last_name: "some content", organization: "some content", title: "some content"}
  @invalid_attrs %{}

  setup do
    conn = conn()
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{generate_auth_token}")
    {:ok, conn: conn}
  end

  test "shows chosen resource", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = get conn, user_path(conn, :show, user)
    assert json_response(conn, 200)["data"] == %{"id" => user.id,
      "first_name" => user.first_name,
      "last_name" => user.last_name,
      "title" => user.title,
      "email" => user.email,
      "organization" => user.organization}
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, user_path(conn, :show, -1)
    end
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = put conn, user_path(conn, :update, user), user: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(User, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = put conn, user_path(conn, :update, user), user: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end
end
