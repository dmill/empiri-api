defmodule EmpiriApi.HypothesisControllerTest do
  use EmpiriApi.ConnCase

  alias EmpiriApi.Hypothesis
  @valid_attrs %{synopsis: "some content", title: "some content"}
  @invalid_attrs %{}

  setup do
    conn = conn() |> put_req_header("accept", "application/json")
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, hypothesis_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    hypothesis = Repo.insert! %Hypothesis{}
    conn = get conn, hypothesis_path(conn, :show, hypothesis)
    assert json_response(conn, 200)["data"] == %{"id" => hypothesis.id,
      "title" => hypothesis.title,
      "synopsis" => hypothesis.synopsis}
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, hypothesis_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, hypothesis_path(conn, :create), hypothesis: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Hypothesis, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, hypothesis_path(conn, :create), hypothesis: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    hypothesis = Repo.insert! %Hypothesis{}
    conn = put conn, hypothesis_path(conn, :update, hypothesis), hypothesis: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Hypothesis, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    hypothesis = Repo.insert! %Hypothesis{}
    conn = put conn, hypothesis_path(conn, :update, hypothesis), hypothesis: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    hypothesis = Repo.insert! %Hypothesis{}
    conn = delete conn, hypothesis_path(conn, :delete, hypothesis)
    assert response(conn, 204)
    refute Repo.get(Hypothesis, hypothesis.id)
  end
end
