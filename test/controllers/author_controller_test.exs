defmodule EmpiriApi.AuthorControllerTest do
  defmodule SharedContext do
    use ExUnit.CaseTemplate

    using do
      quote do
        use EmpiriApi.ConnCase
        alias EmpiriApi.User
        alias EmpiriApi.Publication
        alias EmpiriApi.Author
        alias EmpiriApi.UserPublication

        @valid_attrs %{first_name: "Stewie", last_name: "Griffin",
                       title: "baby", email: "stewie@gmail.com",
                       organization: "whatever"}

        @invalid_attrs %{first_name: nil}

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

      Ecto.build_assoc(publication, :user_publications, user_id: user.id, admin: true)
                 |> Repo.insert!

      {:ok, conn: conn, user: user, publication: publication}
    end

    test "#{@action}: wrong content-type header", %{conn: conn} do
      conn = conn |> put_req_header("content-type", "application/xml")
                  |> post("/publications/1/authors")

      assert json_response(conn, 415)["error"] == "Unsupported Media Type"
    end

    test "#{@action}: no auth header", %{conn: conn} do
      conn = conn |> put_req_header("content-type", "application/json")
                  |> post("/publications/1/authors")

      assert json_response(conn, 401)["error"] == "unauthorized"
    end

    test "#{@action}: no author param", %{conn: conn, publication: publication} do
      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")

       assert_raise Phoenix.MissingParamError, fn ->
        post(conn, "/publications/#{publication.id}/authors", Poison.encode!(%{junk: "garbage"}))
      end
    end


    test "#{@action}: user not found", %{conn: conn} do
      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(%{auth_id: 619})}")
                  |> post("/publications/1/authors", Poison.encode!(%{author: @valid_attrs}))

      assert json_response(conn, 401)
    end

    test "#{@action}: publication not found", %{conn: conn, user: _user} do
      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")

      assert_raise Ecto.NoResultsError, fn ->
        post(conn,
             "/publications/1/authors",
             Poison.encode!(%{author: @valid_attrs}))
      end
    end

    test "#{@action}: creates and renders resource when data is valid", %{conn: conn, user: _user, publication: publication} do
      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")
                  |> post("/publications/#{publication.id}/authors", Poison.encode!(%{author: @valid_attrs}))

      assert json_response(conn, 201)["author"]["title"] == "baby"
      assert (Repo.all(from a in Author,
                      limit: 1,
                      order_by: [desc: a.id])
             |> List.first).first_name == "Stewie"

    end

    test "#{@action}: does not create resource and renders errors when data is invalid", %{conn: conn, user: _user, publication: publication} do
      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")
                  |> post("/publications/#{publication.id}/authors", Poison.encode!(%{author: @invalid_attrs}))

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

      publication = Publication.changeset(%Publication{}, %{title: "some content", last_author_id: 1, first_author_id: 2})
                    |> Repo.insert!

      user_pub = Ecto.build_assoc(publication, :user_publications, user_id: user.id, admin: true)
                 |> Repo.insert!

      {:ok, conn: conn, user: user, publication: publication, user_pub: user_pub}
    end

    test "#{@action}: wrong content-type header", %{conn: conn} do
      conn = conn |> put_req_header("content-type", "application/xml")
                  |> put("/publications/1/authors/1")

      assert json_response(conn, 415)["error"] == "Unsupported Media Type"
    end

    test "#{@action}: no author param", %{conn: conn, user: _user, publication: publication} do
      author = Repo.insert! Author.changeset(%Author{}, @valid_attrs)

       assert_raise Phoenix.MissingParamError, fn ->
        conn |> put_req_header("content-type", "application/json")
             |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")
             |> put("/publications/#{publication.id}/authors/#{author.id}", Poison.encode!(%{junk: "garbage"}))
      end
    end

    test "#{@action}: no auth header", %{conn: conn, user: _user, publication: publication} do
      author = Repo.insert! Author.changeset(%Author{}, @valid_attrs)
      conn = conn |> put_req_header("content-type", "application/json")
                  |> put("/publications/#{publication.id}/authors/#{author.id}", Poison.encode!(%{author: @valid_attrs}))

      assert json_response(conn, 401)["error"] == "unauthorized"
    end

    test "#{@action}: user not found", %{conn: conn, user: _user, publication: publication} do
      author = Repo.insert! Author.changeset(%Author{}, @valid_attrs)
      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(auth_id: 678)}")
                  |> put("/publications/#{publication.id}/authors/#{author.id}", Poison.encode!(%{author: %{first_name: "Bob"}}))

      assert json_response(conn, 401)["error"] == "Unauthorized"
    end

    test "#{@action}: user is not an admin", %{conn: conn, user: _user, publication: publication, user_pub: user_pub} do
      author = Repo.insert! Author.changeset(%Author{}, @valid_attrs)
      UserPublication.changeset(user_pub, %{admin: false}) |> Repo.update

      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")
                  |> put("/publications/#{publication.id}/authors/#{author.id}", Poison.encode!(%{author: %{first_name: "Bob"}}))


      assert json_response(conn, 401)["error"] == "Unauthorized"
    end

    test "#{@action}: does not update resource and renders errors when data is invalid", %{conn: conn, user: _user, publication: publication} do
      author = Ecto.build_assoc(publication, :authors, @valid_attrs) |> Repo.insert!
      conn = conn |> put_req_header("content-type", "application/json")
            |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")
            |> put("/publications/#{publication.id}/authors/#{author.id}", Poison.encode!(%{author: @invalid_attrs}))

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "#{@action}: author not found", %{conn: conn, user: _user, publication: publication} do
      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")

      assert_raise Ecto.NoResultsError, fn ->
        put(conn, "/publications/#{publication.id}/authors/12345", Poison.encode!(%{author: @valid_attrs}))
      end
    end

      test "#{@action}: updates and renders chosen resource when data is valid and user is an admin", %{conn: conn, user: _user, publication: publication} do
        author = Ecto.build_assoc(publication, :authors, @valid_attrs) |> Repo.insert!
        conn = conn |> put_req_header("content-type", "application/json")
                    |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")
                    |> put("/publications/#{publication.id}/authors/#{author.id}", Poison.encode!(%{author: %{first_name: "Bob"}}))

        assert json_response(conn, 200)["author"]["id"]
        assert Repo.get(Author, author.id).first_name == "Bob"
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

      publication = Publication.changeset(%Publication{}, %{title: "some content", last_author_id: 1, first_author_id: 2})
                    |> Repo.insert!

      user_pub = Ecto.build_assoc(publication, :user_publications, user_id: user.id, admin: true)
                 |> Repo.insert!

      {:ok, conn: conn, user: user, publication: publication, user_pub: user_pub}
    end

    test "#{@action}: wrong content-type header", %{conn: conn} do
      conn = conn |> put_req_header("content-type", "application/xml")
                  |> delete("/publications/1/authors/1")

      assert json_response(conn, 415)["error"] == "Unsupported Media Type"
    end

    test "#{@action}: no auth header", %{conn: conn, user: _user, publication: publication} do
      author = Repo.insert! Author.changeset(%Author{}, @valid_attrs)
      conn = conn |> put_req_header("content-type", "application/json")
                  |> delete("/publications/#{publication.id}/authors/#{author.id}")

      assert json_response(conn, 401)["error"] == "unauthorized"
    end

    test "#{@action}: user not found", %{conn: conn, user: _user, publication: publication} do
      author = Repo.insert! Author.changeset(%Author{}, @valid_attrs)
      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(auth_id: 678)}")
                  |> delete("/publications/#{publication.id}/authors/#{author.id}", Poison.encode!(%{author: @valid_attrs}))

      assert json_response(conn, 401)["error"] == "Unauthorized"
    end

    test "#{@action}: user is not an admin", %{conn: conn, user: _user, publication: publication, user_pub: user_pub} do
      author = Repo.insert! Author.changeset(%Author{}, @valid_attrs)
      UserPublication.changeset(user_pub, %{admin: false}) |> Repo.update

      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")
                  |> delete("/publications/#{publication.id}/authors/#{author.id}")


      assert json_response(conn, 401)["error"] == "Unauthorized"
    end

    test "#{@action}: deletes the record when user is an admin", %{conn: conn, user: _user, publication: publication, user_pub: _user_pub} do
      author = Ecto.build_assoc(publication, :authors, @valid_attrs) |> Repo.insert!
      conn = conn |> put_req_header("content-type", "application/json")
                  |> put_req_header("authorization", "Bearer #{generate_auth_token(@user_params)}")
                  |> delete("/publications/#{publication.id}/authors/#{author.id}")

      assert response(conn, 204)
      assert Repo.get(Author, author.id) == nil
    end
  end
end
