defmodule EmpiriApi.HypothesisControllerTest do

  defmodule SharedContext do
    use ExUnit.CaseTemplate

    using do
      quote do
        use EmpiriApi.ConnCase
        alias EmpiriApi.User
        alias EmpiriApi.Hypothesis

        @valid_attrs %{synopsis: "some content", title: "some content"}

        @invalid_attrs %{title: nil}

        @user_attrs %{email: "pugs@gmail.com", first_name: "Pug", last_name: "Jeremy",
                       organization: "Harvard", title: "President",
                       auth_id: "12345", auth_provider: "petco"}

        @user_params %{email: @user_attrs[:email], given_name: @user_attrs[:first_name],
                        family_name: @user_attrs[:last_name], auth_id: @user_attrs[:auth_id],
                        auth_provider: @user_attrs[:auth_provider]}
      end
    end
  end

  defmodule IndexContext do
    use SharedContext

    @action "INDEX"

    setup do
      Enum.each(1..10, fn(x) -> Repo.insert! %Hypothesis{title: "#{x}", deleted: false, private: false} end)
      private_hypo = Repo.insert!(%Hypothesis{private: true, title: "private"})
      deleted_hypo = Repo.insert!(%Hypothesis{deleted: true, title: "deleted"})

      conn = conn() |> put_req_header("accept", "application/json")
      {:ok, conn: conn, deleted_hypo: deleted_hypo, private_hypo: private_hypo}
    end

    test "#{@action}: without params", %{conn: conn, deleted_hypo: deleted_hypo, private_hypo: private_hypo} do
      conn = get conn, hypothesis_path(conn, :index)

      resp = Poison.decode!(response(conn, 200))

      assert json_response(conn, 200)["hypotheses"]
      assert List.first(resp["hypotheses"]) |> Map.fetch!("title") == "10"
      assert Enum.count(resp["hypotheses"]) == 10
      refute Enum.find(resp["hypotheses"], fn(x) -> x["title"] == deleted_hypo.title || x["title"] == private_hypo.title end)
    end

    test "#{@action}: without an offset param", %{conn: conn, deleted_hypo: deleted_hypo, private_hypo: private_hypo} do
      conn = get conn, hypothesis_path(conn, :index, %{limit: 6})

      resp = Poison.decode!(response(conn, 200))

      assert json_response(conn, 200)["hypotheses"]
      assert List.first(resp["hypotheses"]) |> Map.fetch!("title") == "10"
      assert Enum.count(resp["hypotheses"]) == 6
      refute Enum.find(resp["hypotheses"], fn(x) -> x["title"] == deleted_hypo.title || x["title"] == private_hypo.title end)
    end

    test "#{@action}: without a limit param", %{conn: conn, deleted_hypo: deleted_hypo, private_hypo: private_hypo} do
      conn = get conn, hypothesis_path(conn, :index, %{offset: 2})

      resp = Poison.decode!(response(conn, 200))

      assert json_response(conn, 200)["hypotheses"]
      assert List.first(resp["hypotheses"]) |> Map.fetch!("title") == "8"
      assert Enum.count(resp["hypotheses"]) == 8
      refute Enum.find(resp["hypotheses"], fn(x) -> x["title"] == deleted_hypo.title || x["title"] == private_hypo.title end)
    end

    test "#{@action}: with offset and limit params", %{conn: conn, deleted_hypo: deleted_hypo, private_hypo: private_hypo} do
      conn = get conn, hypothesis_path(conn, :index, %{offset: 3, limit: 3})

      resp = Poison.decode!(response(conn, 200))

      assert json_response(conn, 200)["hypotheses"]
      assert List.first(resp["hypotheses"]) |> Map.fetch!("title") == "7"
      assert Enum.count(resp["hypotheses"]) == 3
      refute Enum.find(resp["hypotheses"], fn(x) -> x["title"] == deleted_hypo.title || x["title"] == private_hypo.title end)
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

      assert json_response(conn, 200)["hypothesis"] == %{"id" => hypothesis.id,
        "title" => hypothesis.title,
        "synopsis" => hypothesis.synopsis}
    end

    test "#{@action}: when the hypothesis was deleted", %{conn: conn} do
      attrs = Map.merge(@valid_attrs, %{private: false, deleted: true})
      hypothesis = Repo.insert! Hypothesis.changeset(%Hypothesis{}, attrs)

      assert_raise Ecto.NoResultsError, fn ->
        get conn, hypothesis_path(conn, :show, hypothesis.id)
      end
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

      assert json_response(conn, 200)["hypothesis"] == %{"id" => hypothesis.id,
        "title" => hypothesis.title,
        "synopsis" => hypothesis.synopsis}
    end
  end

  defmodule CreateContext do
    use SharedContext

    @action "CREATE"

    setup do
      conn = conn() |> put_req_header("accept", "application/json")
      user = User.changeset(%User{}, %{email: "pugs@gmail.com", first_name: "Pug", last_name: "Jeremy",
                                organization: "Harvard", title: "President",
                                auth_id: "12345", auth_provider: "petco"}) |> Repo.insert!
      {:ok, conn: conn, user: user}
    end

    test "#{@action}: wrong content-type header", %{conn: conn} do
      conn = conn |> put_req_header("content-type", "application/xml")
                  |> post(hypothesis_path(conn, :create))

      assert json_response(conn, 415)["error"] == "Unsupported Media Type"
    end

    test "#{@action}: no auth header", %{conn: conn} do
      conn = conn |> put_req_header("content-type", "application/json")
                  |> post(hypothesis_path(conn, :create))

      assert json_response(conn, 401)["error"] == "unauthorized"
    end

    test "#{@action}: no hypothesis param", %{conn: conn} do
      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")

       assert_raise Phoenix.MissingParamError, fn ->
        post(conn, hypothesis_path(conn, :create), Poison.encode!(%{junk: "garbage"}))
      end
    end

    test "#{@action}: user not found", %{conn: conn} do
      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(%{auth_id: 619})}")

      assert_raise Ecto.NoResultsError, fn ->
        post(conn, hypothesis_path(conn, :create), Poison.encode!(%{hypothesis: @valid_attrs}))
      end
    end

    test "#{@action}: creates and renders resource when data is valid", %{conn: conn, user: user} do
      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")
                  |> post(hypothesis_path(conn, :create), Poison.encode!(%{hypothesis: @valid_attrs}))

      hypothesis = Repo.get_by(Hypothesis, @valid_attrs) |> Repo.preload([:users, :user_hypotheses])

      assert json_response(conn, 201)["hypothesis"]["title"] == "some content"
      assert hypothesis.users |> Enum.member?(user)
      assert Hypothesis.admins(hypothesis) |> Enum.member?(user)
    end

    test "#{@action}: does not create resource and renders errors when data is invalid", %{conn: conn} do
      conn = conn |> put_req_header("content-type", "application/json")
            |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")
            |> post(hypothesis_path(conn, :create), Poison.encode!(%{hypothesis: @invalid_attrs}))

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  defmodule UpdateContext do
    use SharedContext

    @action "UPDATE"

    setup do
      conn = conn() |> put_req_header("accept", "application/json")
      user = User.changeset(%User{}, %{email: "pugs@gmail.com", first_name: "Pug", last_name: "Jeremy",
                                organization: "Harvard", title: "President",
                                auth_id: "12345", auth_provider: "petco"}) |> Repo.insert!
      {:ok, conn: conn, user: user}
    end

    test "#{@action}: wrong content-type header", %{conn: conn} do
      conn = conn |> put_req_header("content-type", "application/xml")
                  |> put(hypothesis_path(conn, :update, 33))

      assert json_response(conn, 415)["error"] == "Unsupported Media Type"
    end

    test "#{@action}: no hypothesis param", %{conn: conn} do
      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")

       assert_raise Phoenix.MissingParamError, fn ->
        put(conn, hypothesis_path(conn, :update, 33), Poison.encode!(%{junk: "garbage"}))
      end
    end

    test "#{@action}: no auth header", %{conn: conn} do
      hypothesis = Repo.insert! %Hypothesis{}
      conn = conn |> put_req_header("content-type", "application/json")
                  |> put(hypothesis_path(conn, :update, hypothesis), Poison.encode!(%{hypothesis: @valid_attrs}))

      assert json_response(conn, 401)["error"] == "unauthorized"
    end

    test "#{@action}: user not found", %{conn: conn} do
      hypothesis = Repo.insert! %Hypothesis{}
      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")
                  |> put(hypothesis_path(conn, :update, hypothesis), Poison.encode!(%{hypothesis: @valid_attrs}))

      assert json_response(conn, 401)["error"] == "Unauthorized"
    end

    test "#{@action}: user is not an admin", %{conn: conn, user: user} do
      hypothesis = Repo.insert! Hypothesis.changeset(%Hypothesis{}, %{title: "title"})
      Ecto.build_assoc(hypothesis, :user_hypotheses, user_id: user.id, admin: false) |> Repo.insert

      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")
                  |> put(hypothesis_path(conn, :update, hypothesis), Poison.encode!(%{hypothesis: @valid_attrs}))


      assert json_response(conn, 401)["error"] == "Unauthorized"
    end

    test "#{@action}: does not create resource and renders errors when data is invalid", %{conn: conn} do
      conn = conn |> put_req_header("content-type", "application/json")
            |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")
            |> post(hypothesis_path(conn, :create), Poison.encode!(%{hypothesis: @invalid_attrs}))

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "#{@action}: hypothesis is deleted", %{conn: conn, user: user} do
      hypothesis = Repo.insert! Hypothesis.changeset(%Hypothesis{}, %{title: "title", deleted: true})
      Ecto.build_assoc(hypothesis, :user_hypotheses, user_id: user.id, admin: true) |> Repo.insert

      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")

      assert_raise Ecto.NoResultsError, fn ->
        put(conn, hypothesis_path(conn, :update, hypothesis), Poison.encode!(%{hypothesis: @valid_attrs}))
      end
    end

    test "#{@action}: hypothesis not found", %{conn: conn} do
      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")

      assert_raise Ecto.NoResultsError, fn ->
        put(conn, hypothesis_path(conn, :update, 32), Poison.encode!(%{hypothesis: @valid_attrs}))
      end
    end

      test "#{@action}: updates and renders chosen resource when data is valid and user is an admin", %{conn: conn, user: user} do
        hypothesis = Repo.insert! Hypothesis.changeset(%Hypothesis{}, %{title: "title"})
        Ecto.build_assoc(hypothesis, :user_hypotheses, user_id: user.id, admin: true) |> Repo.insert

        conn = conn |> put_req_header("content-type", "application/json")
                    |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")
                    |> put(hypothesis_path(conn, :update, hypothesis), Poison.encode!(%{hypothesis: @valid_attrs}))

        assert json_response(conn, 200)["hypothesis"]["id"]
        assert Repo.get_by(Hypothesis, @valid_attrs)
      end
  end

  defmodule DeleteContext do
    use SharedContext

    @action "DELETE"

    setup do
      conn = conn() |> put_req_header("accept", "application/json")
      user = User.changeset(%User{}, %{email: "pugs@gmail.com", first_name: "Pug", last_name: "Jeremy",
                                organization: "Harvard", title: "President",
                                auth_id: "12345", auth_provider: "petco"}) |> Repo.insert!
      {:ok, conn: conn, user: user}
    end

    test "#{@action}: wrong content-type header", %{conn: conn} do
      conn = conn |> put_req_header("content-type", "application/xml")
                  |> delete(hypothesis_path(conn, :delete, 33))

      assert json_response(conn, 415)["error"] == "Unsupported Media Type"
    end

    test "#{@action}: no auth header", %{conn: conn} do
      hypothesis = Repo.insert! %Hypothesis{}
      conn = conn |> put_req_header("content-type", "application/json")
                  |> delete(hypothesis_path(conn, :delete, hypothesis))

      assert json_response(conn, 401)["error"] == "unauthorized"
    end

    test "#{@action}: user not found", %{conn: conn} do
      hypothesis = Repo.insert! %Hypothesis{}
      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")
                  |> delete(hypothesis_path(conn, :delete, hypothesis))

      assert json_response(conn, 401)["error"] == "Unauthorized"
    end

    test "#{@action}: user is not an admin", %{conn: conn, user: user} do
      hypothesis = Repo.insert! Hypothesis.changeset(%Hypothesis{}, %{title: "title"})
      Ecto.build_assoc(hypothesis, :user_hypotheses, user_id: user.id, admin: false) |> Repo.insert

      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")
                  |> delete(hypothesis_path(conn, :delete, hypothesis))


      assert json_response(conn, 401)["error"] == "Unauthorized"
    end

    test "#{@action}: hypothesis is already deleted", %{conn: conn, user: user} do
      hypothesis = Repo.insert! Hypothesis.changeset(%Hypothesis{}, %{title: "title", deleted: true})
      Ecto.build_assoc(hypothesis, :user_hypotheses, user_id: user.id, admin: true) |> Repo.insert

      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")

      assert_raise Ecto.NoResultsError, fn ->
        delete(conn, hypothesis_path(conn, :delete, hypothesis))
      end
    end

    test "#{@action}: soft-deletes the record when user is an admin", %{conn: conn, user: user} do
      hypothesis = Repo.insert! Hypothesis.changeset(%Hypothesis{}, %{title: "title"})
      Ecto.build_assoc(hypothesis, :user_hypotheses, user_id: user.id, admin: true) |> Repo.insert

      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")
                  |> delete(hypothesis_path(conn, :delete, hypothesis))

      assert response(conn, 204)
      assert Repo.get(Hypothesis, hypothesis.id).deleted
    end
  end
end
