defmodule EmpiriApi.SectionControllerTest do
defmodule SharedContext do
    use ExUnit.CaseTemplate

    using do
      quote do
        use EmpiriApi.ConnCase
        alias EmpiriApi.User
        alias EmpiriApi.Publication

        @valid_attrs %{title: "some content", body: "blah", position: 2}

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


  defmodule CreateContext do
    use SharedContext

    @action "CREATE"

    setup do
      conn = conn() |> put_req_header("accept", "application/json")
      user = User.changeset(%User{}, %{email: "pugs@gmail.com", first_name: "Pug", last_name: "Jeremy",
                                organization: "Harvard", title: "President",
                                auth_id: "12345", auth_provider: "petco"}) |> Repo.insert!

      publication = Publication.changeset(%Publication{}, %{title: "some content", last_author_id: 1, first_author_id: 2})
                    |> Repo.insert!

      {:ok, conn: conn, user: user, publication: publication}
    end

    test "#{@action}: wrong content-type header", %{conn: conn} do
      conn = conn |> put_req_header("content-type", "application/xml")
                  |> post("/publications/1/sections")

      assert json_response(conn, 415)["error"] == "Unsupported Media Type"
    end

    test "#{@action}: no auth header", %{conn: conn} do
      conn = conn |> put_req_header("content-type", "application/json")
                  |> post("/publications/1/sections")

      assert json_response(conn, 401)["error"] == "unauthorized"
    end

    test "#{@action}: no publication param", %{conn: conn} do
      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")

       assert_raise Phoenix.MissingParamError, fn ->
        post(conn, "/publications/1/sections", Poison.encode!(%{junk: "garbage"}))
      end
    end


    test "#{@action}: user not found", %{conn: conn} do
      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(%{auth_id: 619})}")
                  |> post("/publications/1/sections", Poison.encode!(%{section: @valid_attrs}))

      assert json_response(conn, 401)
    end

    test "#{@action}: publication not found", %{conn: conn, user: user} do
      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")

      assert_raise Ecto.NoResultsError, fn ->
        post(conn,
             "/publications/1/sections",
             Poison.encode!(%{section: @valid_attrs}))
      end
    end

    test "#{@action}: creates and renders resource when data is valid", %{conn: conn, user: user, publication: publication} do
      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")
                  |> post("/publications/#{publication.id}/sections", Poison.encode!(%{section: @valid_attrs}))

      assert json_response(conn, 201)["section"]["title"] == "some content"
      assert (Repo.all(from p in Publication,
                      limit: 1,
                      order_by: [desc: p.id])
             |> List.first).title == "some content"

    end

    test "#{@action}: does not create resource and renders errors when data is invalid", %{conn: conn, user: user, publication: publication} do
      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")
                  |> post("/publications/#{publication.id}/sections", Poison.encode!(%{section: @invalid_attrs}))

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

    test "#{@action}: no publication param", %{conn: conn, user: user} do
      publication = Repo.insert! Publication.changeset(%Publication{}, %{title: "title"})
      Ecto.build_assoc(publication, :user_publications, user_id: user.id, admin: true) |> Repo.insert

      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")

       assert_raise Phoenix.MissingParamError, fn ->
        put(conn, publication_path(conn, :update, publication), Poison.encode!(%{junk: "garbage"}))
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
                  |> put(publication_path(conn, :update, publication), Poison.encode!(%{publication: @valid_attrs}))

      assert json_response(conn, 404)
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
                  |> delete(publication_path(conn, :delete, publication))

      assert json_response(conn, 404)
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
