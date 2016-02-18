defmodule EmpiriApi.PublicationControllerTest do
defmodule SharedContext do
    use ExUnit.CaseTemplate

    using do
      quote do
        use EmpiriApi.ConnCase
        alias EmpiriApi.User
        alias EmpiriApi.Publication

        @valid_attrs %{title: "some content", last_author_id: 1, first_author_id: 2}

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
      Enum.each(1..10, fn(x) -> Repo.insert! %Publication{title: "#{x}", deleted: false, published: true} end)
      private_pub = Repo.insert!(%Publication{published: false, title: "private"})
      deleted_pub = Repo.insert!(%Publication{deleted: true, title: "deleted"})

      conn = conn() |> put_req_header("accept", "application/json")
      {:ok, conn: conn, deleted_pub: deleted_pub, private_pub: private_pub}
    end

    test "#{@action}: without params", %{conn: conn, deleted_pub: deleted_pub, private_pub: private_pub} do
      conn = get conn, publication_path(conn, :index)

      resp = Poison.decode!(response(conn, 200))

      assert json_response(conn, 200)["publications"]
      assert List.first(resp["publications"]) |> Map.fetch!("title") == "10"
      assert Enum.count(resp["publications"]) == 10
      refute Enum.find(resp["publications"], fn(x) -> x["title"] == deleted_pub.title || x["title"] == private_pub.title end)
    end

    test "#{@action}: without an offset param", %{conn: conn, deleted_pub: deleted_pub, private_pub: private_pub} do
      conn = get conn, publication_path(conn, :index, %{limit: 6})

      resp = Poison.decode!(response(conn, 200))

      assert json_response(conn, 200)["publications"]
      assert List.first(resp["publications"]) |> Map.fetch!("title") == "10"
      assert Enum.count(resp["publications"]) == 6
      refute Enum.find(resp["publications"], fn(x) -> x["title"] == deleted_pub.title || x["title"] == private_pub.title end)
    end

    test "#{@action}: without a limit param", %{conn: conn, deleted_pub: deleted_pub, private_pub: private_pub} do
      conn = get conn, publication_path(conn, :index, %{offset: 2})

      resp = Poison.decode!(response(conn, 200))

      assert json_response(conn, 200)["publications"]
      assert List.first(resp["publications"]) |> Map.fetch!("title") == "8"
      assert Enum.count(resp["publications"]) == 8
      refute Enum.find(resp["publications"], fn(x) -> x["title"] == deleted_pub.title || x["title"] == private_pub.title end)
    end

    test "#{@action}: with offset and limit params", %{conn: conn, deleted_pub: deleted_pub, private_pub: private_pub} do
      conn = get conn, publication_path(conn, :index, %{offset: 3, limit: 3})

      resp = Poison.decode!(response(conn, 200))

      assert json_response(conn, 200)["publications"]
      assert List.first(resp["publications"]) |> Map.fetch!("title") == "7"
      assert Enum.count(resp["publications"]) == 3
      refute Enum.find(resp["publications"], fn(x) -> x["title"] == deleted_pub.title || x["title"] == private_pub.title end)
    end
  end


  defmodule ShowContext do
    use SharedContext

    @action "SHOW"

    setup do
      conn = conn() |> put_req_header("accept", "application/json")
      {:ok, conn: conn}
    end

    test "#{@action}: when the publication was deleted", %{conn: conn} do
      attrs = Map.merge(@valid_attrs, %{published: true, deleted: true})
      publication = Repo.insert! Publication.changeset(%Publication{}, attrs)

      assert_raise Ecto.NoResultsError, fn ->
        get conn, publication_path(conn, :show, publication.id)
      end
    end

    test "#{@action}: does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
      assert_raise Ecto.NoResultsError, fn ->
        get conn, publication_path(conn, :show, 13)
      end
    end

    test "#{@action}: when the publication has not been published, 401 without an authorization header" do
      publication = Publication.changeset(%Publication{}, @valid_attrs) |> Repo.insert!
      user = User.changeset(%User{}, @user_attrs) |> Repo.insert!
      Ecto.build_assoc(publication, :user_publications, user_id: user.id) |> Repo.insert!

      conn = get conn, publication_path(conn, :show, publication.id)

      assert json_response(conn, 401)["error"] == "unauthorized"
    end

    test "#{@action}: when the publication has not been published, 401 if the user is not authorized" do
      publication = Publication.changeset(%Publication{}, @valid_attrs) |> Repo.insert!
      user = User.changeset(%User{}, @user_attrs) |> Repo.insert!
      Ecto.build_assoc(publication, :user_publications, user_id: user.id) |> Repo.insert!

      conn = conn |> put_req_header("authorization", "Bearer #{generate_auth_token(%{auth_id: 619})}")
      conn = get conn, publication_path(conn, :show, publication.id)

      assert json_response(conn, 401)["error"] == "Unauthorized"
    end

    test "#{@action}: when the publication has not been published, 200 if the user is authorized", %{conn: conn} do
      publication = Publication.changeset(%Publication{}, @valid_attrs) |> Repo.insert!
      user = User.changeset(%User{}, @user_attrs) |> Repo.insert!
      Ecto.build_assoc(publication, :user_publications, user_id: user.id) |> Repo.insert!
      Ecto.build_assoc(publication, :authors, first_name: "Buster",
                                              last_name: "Garcia",
                                              title: "pug",
                                              organization: "petco",
                                              email: "pug@petco.com") |> Repo.insert!


      conn = conn |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")
      conn = get conn, publication_path(conn, :show, publication.id)

      assert json_response(conn, 200)["publication"]["id"] == publication.id
      assert json_response(conn, 200)["publication"]["admin_ids"]
      assert json_response(conn, 200)["publication"]["first_author_id"]
      assert json_response(conn, 200)["publication"]["last_author_id"]
      assert json_response(conn, 200)["publication"]["_embedded"]["authors"] |> List.first |> Map.get("first_name") == "Buster"
      assert json_response(conn, 200)["publication"]["_embedded"]["users"] |>
             Enum.map(fn(u) -> u["id"] end) |>
             Enum.member?(user.id)
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
                  |> post(publication_path(conn, :create))

      assert json_response(conn, 415)["error"] == "Unsupported Media Type"
    end

    test "#{@action}: no auth header", %{conn: conn} do
      conn = conn |> put_req_header("content-type", "application/json")
                  |> post(publication_path(conn, :create))

      assert json_response(conn, 401)["error"] == "unauthorized"
    end

    test "#{@action}: no publication param", %{conn: conn} do
      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")

       assert_raise Phoenix.MissingParamError, fn ->
        post(conn, publication_path(conn, :create), Poison.encode!(%{junk: "garbage"}))
      end
    end

    test "#{@action}: user not found", %{conn: conn} do
      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(%{auth_id: 619})}")

      assert_raise Ecto.NoResultsError, fn ->
        post(conn, publication_path(conn, :create), Poison.encode!(%{publication: @valid_attrs}))
      end
    end

    test "#{@action}: creates and renders resource when data is valid", %{conn: conn, user: user} do
      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")
                  |> post(publication_path(conn, :create), Poison.encode!(%{publication: @valid_attrs}))

      publication = Repo.get_by(Publication, @valid_attrs) |> Repo.preload([:users, :user_publications])

      assert json_response(conn, 201)["publication"]["title"] == "some content"
      assert publication.users |> Enum.member?(user)
      assert Publication.admins(publication) |> Enum.member?(user)
    end

    test "#{@action}: does not create resource and renders errors when data is invalid", %{conn: conn} do
      conn = conn |> put_req_header("content-type", "application/json")
            |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")
            |> post(publication_path(conn, :create), Poison.encode!(%{publication: @invalid_attrs}))

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
                  |> put(publication_path(conn, :update, 33))

      assert json_response(conn, 415)["error"] == "Unsupported Media Type"
    end

    test "#{@action}: no publication param", %{conn: conn} do
      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")

       assert_raise Phoenix.MissingParamError, fn ->
        put(conn, publication_path(conn, :update, 33), Poison.encode!(%{junk: "garbage"}))
      end
    end

    test "#{@action}: no auth header", %{conn: conn} do
      publication = Repo.insert! %Publication{}
      conn = conn |> put_req_header("content-type", "application/json")
                  |> put(publication_path(conn, :update, publication), Poison.encode!(%{publication: @valid_attrs}))

      assert json_response(conn, 401)["error"] == "unauthorized"
    end

    test "#{@action}: user not found", %{conn: conn} do
      publication = Repo.insert! %Publication{}
      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")
                  |> put(publication_path(conn, :update, publication), Poison.encode!(%{publication: @valid_attrs}))

      assert json_response(conn, 401)["error"] == "Unauthorized"
    end

    test "#{@action}: user is not an admin", %{conn: conn, user: user} do
      publication = Repo.insert! Publication.changeset(%Publication{}, %{title: "title"})
      Ecto.build_assoc(publication, :user_publications, user_id: user.id, admin: false) |> Repo.insert

      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")
                  |> put(publication_path(conn, :update, publication), Poison.encode!(%{publication: @valid_attrs}))


      assert json_response(conn, 401)["error"] == "Unauthorized"
    end

    test "#{@action}: does not update resource and renders errors when data is invalid", %{conn: conn} do
      conn = conn |> put_req_header("content-type", "application/json")
            |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")
            |> post(publication_path(conn, :create), Poison.encode!(%{publication: @invalid_attrs}))

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "#{@action}: publication is deleted", %{conn: conn, user: user} do
      publication = Repo.insert! Publication.changeset(%Publication{}, %{title: "title", deleted: true})
      Ecto.build_assoc(publication, :user_publications, user_id: user.id, admin: true) |> Repo.insert

      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")

      assert_raise Ecto.NoResultsError, fn ->
        put(conn, publication_path(conn, :update, publication), Poison.encode!(%{publication: @valid_attrs}))
      end
    end

    test "#{@action}: publication not found", %{conn: conn} do
      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")

      assert_raise Ecto.NoResultsError, fn ->
        put(conn, publication_path(conn, :update, 32), Poison.encode!(%{publication: @valid_attrs}))
      end
    end

      test "#{@action}: updates and renders chosen resource when data is valid and user is an admin", %{conn: conn, user: user} do
        publication = Repo.insert! Publication.changeset(%Publication{}, %{title: "title"})
        Ecto.build_assoc(publication, :user_publications, user_id: user.id, admin: true) |> Repo.insert

        conn = conn |> put_req_header("content-type", "application/json")
                    |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")
                    |> put(publication_path(conn, :update, publication), Poison.encode!(%{publication: @valid_attrs}))

        assert json_response(conn, 200)["publication"]["id"]
        assert Repo.get_by(Publication, @valid_attrs)
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
                  |> delete(publication_path(conn, :delete, 33))

      assert json_response(conn, 415)["error"] == "Unsupported Media Type"
    end

    test "#{@action}: no auth header", %{conn: conn} do
      publication = Repo.insert! %Publication{}
      conn = conn |> put_req_header("content-type", "application/json")
                  |> delete(publication_path(conn, :delete, publication))

      assert json_response(conn, 401)["error"] == "unauthorized"
    end

    test "#{@action}: user not found", %{conn: conn} do
      publication = Repo.insert! %Publication{}
      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")
                  |> delete(publication_path(conn, :delete, publication))

      assert json_response(conn, 401)["error"] == "Unauthorized"
    end

    test "#{@action}: user is not an admin", %{conn: conn, user: user} do
      publication = Repo.insert! Publication.changeset(%Publication{}, %{title: "title"})
      Ecto.build_assoc(publication, :user_publications, user_id: user.id, admin: false) |> Repo.insert

      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")
                  |> delete(publication_path(conn, :delete, publication))


      assert json_response(conn, 401)["error"] == "Unauthorized"
    end

    test "#{@action}: publication is already deleted", %{conn: conn, user: user} do
      publication = Repo.insert! Publication.changeset(%Publication{}, %{title: "title", deleted: true})
      Ecto.build_assoc(publication, :user_publications, user_id: user.id, admin: true) |> Repo.insert

      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")

      assert_raise Ecto.NoResultsError, fn ->
        delete(conn, publication_path(conn, :delete, publication))
      end
    end

    test "#{@action}: soft-deletes the record when user is an admin", %{conn: conn, user: user} do
      publication = Repo.insert! Publication.changeset(%Publication{}, %{title: "title"})
      Ecto.build_assoc(publication, :user_publications, user_id: user.id, admin: true) |> Repo.insert

      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")
                  |> delete(publication_path(conn, :delete, publication))

      assert response(conn, 204)
      assert Repo.get(Publication, publication.id).deleted
    end
  end
end
