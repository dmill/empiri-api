defmodule EmpiriApi.HypothesisControllerTest do

  defmodule SharedContext do
    use ExUnit.CaseTemplate

    using do
      quote do
        use EmpiriApi.ConnCase
        alias EmpiriApi.User
        alias EmpiriApi.Hypothesis

        @valid_attrs %{synopsis: "some content", title: "some content"}

        @invalid_attrs %{}

        @user_attrs %{email: "pugs@gmail.com", first_name: "Pug", last_name: "Jeremy",
                       organization: "Harvard", title: "President",
                       auth_id: "12345", auth_provider: "petco"}

        @user_params %{email: @user_attrs[:email], given_name: @user_attrs[:first_name],
                        family_name: @user_attrs[:last_name], auth_id: @user_attrs[:auth_id],
                        auth_provider: @user_attrs[:auth_provider]}
      end
    end
  end

  defmodule ShowContext do
    use SharedContext

    @action "SHOW"

    setup do
      conn = conn() |> put_req_header("accept", "application/json")
      {:ok, conn: conn}
    end

    test "#{@action}: shows chosen resource", %{conn: conn} do
      attrs = Map.merge(@valid_attrs, %{private: false})
      hypothesis = Repo.insert! Hypothesis.changeset(%Hypothesis{}, attrs)
      conn = get conn, hypothesis_path(conn, :show, hypothesis.id)

      assert json_response(conn, 200)["data"] == %{"id" => hypothesis.id,
        "title" => hypothesis.title,
        "synopsis" => hypothesis.synopsis}
    end

    test "#{@action}: does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
      assert_raise Ecto.NoResultsError, fn ->
        get conn, hypothesis_path(conn, :show, 13)
      end
    end

    test "#{@action}: when the hypothesis is private, 401 without an authorization header" do
      hypothesis = Hypothesis.changeset(%Hypothesis{}, @valid_attrs) |> Repo.insert!
      user = User.changeset(%User{}, @user_attrs) |> Repo.insert!
      Ecto.build_assoc(hypothesis, :user_hypotheses, user_id: user.id) |> Repo.insert!

      conn = get conn, hypothesis_path(conn, :show, hypothesis.id)

      assert json_response(conn, 401)["error"] == "unauthorized"
    end

    test "#{@action}: when the hypothesis is private, 401 if the user is not authorized" do
      hypothesis = Hypothesis.changeset(%Hypothesis{}, @valid_attrs) |> Repo.insert!
      user = User.changeset(%User{}, @user_attrs) |> Repo.insert!
      Ecto.build_assoc(hypothesis, :user_hypotheses, user_id: user.id) |> Repo.insert!

      conn = conn |> put_req_header("authorization", "Bearer #{generate_auth_token(%{auth_id: 619})}")
      conn = get conn, hypothesis_path(conn, :show, hypothesis.id)

      assert json_response(conn, 401)["error"] == "Unauthorized"
    end

    test "#{@action}: when the hypothesis is private, 200 if the user is authorized", %{conn: conn} do
      hypothesis = Hypothesis.changeset(%Hypothesis{}, @valid_attrs) |> Repo.insert!
      user = User.changeset(%User{}, @user_attrs) |> Repo.insert!
      Ecto.build_assoc(hypothesis, :user_hypotheses, user_id: user.id) |> Repo.insert!

      conn = conn |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")
      conn = get conn, hypothesis_path(conn, :show, hypothesis.id)

      assert json_response(conn, 200)["data"] == %{"id" => hypothesis.id,
        "title" => hypothesis.title,
        "synopsis" => hypothesis.synopsis}
    end
  end



  # test "creates and renders resource when data is valid", %{conn: conn} do
    # conn = post conn, hypothesis_path(conn, :create), Poison.encode!(%{hypothesis: @valid_attrs})
    # assert json_response(conn, 201)["data"]["id"]
    # assert Repo.get_by(Hypothesis, @valid_attrs)
  # end
#
  # test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    # conn = post conn, hypothesis_path(conn, :create), Poison.encode!(%{hypothesis: @invalid_attrs})
    # assert json_response(conn, 422)["errors"] != %{}
  # end
#
  # test "updates and renders chosen resource when data is valid", %{conn: conn} do
    # hypothesis = Repo.insert! %Hypothesis{}
    # conn = put conn, hypothesis_path(conn, :update, hypothesis), Poison.encode!(%{hypothesis: @valid_attrs})
    # assert json_response(conn, 200)["data"]["id"]
    # assert Repo.get_by(Hypothesis, @valid_attrs)
  # end
#
  # test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    # hypothesis = Repo.insert! %Hypothesis{}
    # conn = put conn, hypothesis_path(conn, :update, hypothesis), Poison.encode!(%{hypothesis: @invalid_attrs})
    # assert json_response(conn, 422)["errors"] != %{}
  # end
#
  # test "deletes chosen resource", %{conn: conn} do
    # hypothesis = Repo.insert! %Hypothesis{}
    # conn = delete conn, hypothesis_path(conn, :delete, hypothesis)
    # assert response(conn, 204)
    # refute Repo.get(Hypothesis, hypothesis.id)
  # end
end
