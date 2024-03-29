defmodule EmpiriApi.UserControllerTest do

  defmodule SharedContext do
    use ExUnit.CaseTemplate

    using do
      quote do
        use EmpiriApi.ConnCase
        alias EmpiriApi.User
        alias EmpiriApi.Publication

        @context_desc %{existing_record: "specified record exists",
                        new_record: "specified record doesn't exist",
                        valid: "params are valid",
                        invalid: "params are invalid"}

        @valid_attrs %{email: "pugs@gmail.com", first_name: "Pug", last_name: "Jeremy",
                       organization: "Harvard", title: "President",
                       auth_id: "12345", auth_provider: "petco"}

        @valid_params %{email: @valid_attrs[:email], given_name: @valid_attrs[:first_name],
                        family_name: @valid_attrs[:last_name], auth_id: @valid_attrs[:auth_id],
                        auth_provider: @valid_attrs[:auth_provider]}

        @invalid_params %{auth_id: "12345"}
      end
    end
  end

  defmodule LoginContext do
    use SharedContext

    @action "LOGIN"

    setup do
      conn = conn() |> put_req_header("content-type", "application/json")
      {:ok, conn: conn}
    end

    test "#{@action}: #{@context_desc[:existing_record]}, shows resource from db", %{conn: conn} do
      conn = conn |> put_req_header("authorization", "Bearer #{generate_auth_token(@valid_params)}")
      user = Repo.insert! Map.merge(%User{},@valid_attrs)
      published_pub = Map.merge(%Publication{}, %{title: "title", published: true}) |> Repo.insert!
      unpublished_pub = Map.merge(%Publication{}, %{title: "titulo", published: false}) |> Repo.insert!

      Ecto.build_assoc(user, :user_publications, publication_id: published_pub.id) |> Repo.insert!
      Ecto.build_assoc(user, :user_publications, publication_id: unpublished_pub.id) |> Repo.insert!

      conn = get conn, user_path(conn, :login)
      assert json_response(conn, 200)["user"]["first_name"] == user.first_name
      assert json_response(conn, 200)["user"]["_embedded"]["publications"] |> Enum.count == 2
    end

    test "#{@action}: #{@context_desc[:existing_record]}, does not insert into db", %{conn: conn} do
      conn = conn |> put_req_header("authorization", "Bearer #{generate_auth_token(@valid_params)}")
      Repo.insert! Map.merge(%User{},@valid_attrs)
      count_fun = fn() -> Repo.all(from u in User, select: count(u.id)) |> List.first end
      user_count = count_fun.()
      get conn, user_path(conn, :login)

      assert count_fun.() == user_count
    end

    test "#{@action}: #{@context_desc[:new_record]},#{@context_desc[:invalid]}, does not insert into db", %{conn: conn} do
      conn = conn |> put_req_header("authorization", "Bearer #{generate_auth_token(@invalid_params)}")
      count_fun = fn() -> Repo.all(from u in User, select: count(u.id)) |> List.first end
      user_count = count_fun.()
      get conn, user_path(conn, :login)

      assert count_fun.() == user_count
    end

    test "#{@action}: #{@context_desc[:new_record]},#{@context_desc[:invalid]}, returns an error", %{conn: conn} do
      conn = conn |> put_req_header("authorization", "Bearer #{generate_auth_token(@invalid_params)}")
      conn = get conn, user_path(conn, :login)
      assert json_response(conn, 422)["errors"] != nil
    end

    test "#{@action}: #{@context_desc[:new_record]},#{@context_desc[:valid]}, inserts into db", %{conn: conn} do
      conn = conn |> put_req_header("authorization", "Bearer #{generate_auth_token(@valid_params)}")
      count_fun = fn() -> Repo.all(from u in User, select: count(u.id)) |> List.first end
      user_count = count_fun.()
      get conn, user_path(conn, :login)

      assert count_fun.() == user_count + 1
    end

    test "#{@action}: #{@context_desc[:new_record]},#{@context_desc[:valid]}, returns user data", %{conn: conn} do
      conn = conn |> put_req_header("authorization", "Bearer #{generate_auth_token(@valid_params)}")
      conn = get conn, user_path(conn, :login)
      assert json_response(conn, 200)["user"]["first_name"] == @valid_params[:given_name]

    end
  end


defmodule ShowContext do
    use SharedContext

    @action "SHOW"

    setup do
      conn = conn() |> put_req_header("content-type", "application/json")
      {:ok, conn: conn}
    end

    test "#{@action}: for anonymous user - resource exists, shows resource from db and only shows published publications", %{conn: conn} do
      user = Repo.insert! Map.merge(%User{},@valid_attrs)
      published_pub = Map.merge(%Publication{}, %{title: "title", published: true}) |> Repo.insert!
      unpublished_pub = Map.merge(%Publication{}, %{title: "titulo", published: false}) |> Repo.insert!

      Ecto.build_assoc(user, :user_publications, publication_id: published_pub.id) |> Repo.insert!
      Ecto.build_assoc(user, :user_publications, publication_id: unpublished_pub.id) |> Repo.insert!

      conn = get conn, user_path(conn, :show, user.id)
      assert json_response(conn, 200)["user"]["first_name"] == user.first_name
      assert json_response(conn, 200)["user"]["_embedded"]["publications"] |> Enum.count == 1
      assert json_response(conn, 200)["user"]["_embedded"]["publications"] |> List.first |> Map.get("title") == "title"
    end


    test "#{@action}: for logged-in user - resource exists, shows resource from db and all publications", %{conn: conn} do
      user = Repo.insert! Map.merge(%User{},@valid_attrs)
      published_pub = Map.merge(%Publication{}, %{title: "title", published: true}) |> Repo.insert!
      unpublished_pub = Map.merge(%Publication{}, %{title: "titulo", published: false}) |> Repo.insert!

      Ecto.build_assoc(user, :user_publications, publication_id: published_pub.id) |> Repo.insert!
      Ecto.build_assoc(user, :user_publications, publication_id: unpublished_pub.id) |> Repo.insert!

      conn = conn
              |> put_req_header("authorization", "Bearer #{generate_auth_token(@valid_params)}")
              |> get(user_path(conn, :show, user.id))

      assert json_response(conn, 200)["user"]["first_name"] == user.first_name
      assert json_response(conn, 200)["user"]["_embedded"]["publications"] |> Enum.count == 2
      assert json_response(conn, 200)["user"]["_embedded"]["publications"] |> List.first |> Map.get("title") == "title"
    end

    test "#{@action}: for wrong logged-in user - resource exists, shows resource from db but restricts unpublished", %{conn: conn} do
      user = Repo.insert! Map.merge(%User{},@valid_attrs)
      published_pub = Map.merge(%Publication{}, %{title: "title", published: true}) |> Repo.insert!
      unpublished_pub = Map.merge(%Publication{}, %{title: "titulo", published: false}) |> Repo.insert!

      Ecto.build_assoc(user, :user_publications, publication_id: published_pub.id) |> Repo.insert!
      Ecto.build_assoc(user, :user_publications, publication_id: unpublished_pub.id) |> Repo.insert!

      conn = conn
              |> put_req_header("authorization", "Bearer #{generate_auth_token(%{auth_provider: "junk", auth_id: "35"})}")
              |> get(user_path(conn, :show, user.id))

      assert json_response(conn, 200)["user"]["first_name"] == user.first_name
      assert json_response(conn, 200)["user"]["_embedded"]["publications"] |> Enum.count == 1
      assert json_response(conn, 200)["user"]["_embedded"]["publications"] |> List.first |> Map.get("title") == "title"
    end

    test "#{@action}: resource does not exist, returns 404", %{conn: conn} do
      assert_raise Ecto.NoResultsError, fn ->
        get conn, user_path(conn, :show, 60)
      end
    end
  end

  defmodule UpdateContext do
    use SharedContext

    @action "UPDATE"

    setup do
      conn = conn()
              |> put_req_header("content-type", "application/json")
              |> put_req_header("authorization", "Bearer #{generate_auth_token(@valid_params)}")
      valid_attrs = Map.drop(@valid_attrs, [:auth_provider, :auth_id])
      {:ok, conn: conn, valid_attrs: valid_attrs}
    end

    test "#{@action}: resource not found", %{conn: conn, valid_attrs: valid_attrs} do
      conn = put conn, user_path(conn, :update, 77), Poison.encode!(%{user: valid_attrs})
      assert json_response(conn, 404)["error"] == "Not Found"
    end

    test "#{@action}: resource found, user is unauthorized", %{conn: conn} do
      second_user_attrs = %{email: "guy@gmail.com", first_name: "Pug", last_name: "Jeremy",
                            organization: "Harvard", title: "President",
                            auth_id: "1234567", auth_provider: "petco"}
      Repo.insert! Map.merge(%User{}, @valid_attrs)
      user2 = Repo.insert! Map.merge(%User{}, second_user_attrs)
      conn = put conn, user_path(conn, :update, user2.id), Poison.encode!(%{user: %{email: "valid@example.com"}})
      assert json_response(conn, 401)["error"] == "Unauthorized"
    end

    test "#{@action}: resource found, data invalid", %{conn: conn} do
      user = Repo.insert! User.changeset(%User{}, @valid_attrs)
      conn = conn |> put_req_header("content-type", "application/json")
      conn = put conn, user_path(conn, :update, user.id), Poison.encode!(%{user: %{email: "invalid-email-string"}})
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "#{@action}: resource found, data is valid", %{conn: conn} do
      user  = Repo.insert! Map.merge(%User{}, @valid_attrs)
      conn = put conn, user_path(conn, :update, user.id), Poison.encode!(%{user: %{email: "valid@example.com"}})
      assert json_response(conn, 200)["user"] == %{"id" => user.id,
        "first_name" => user.first_name,
        "last_name" => user.last_name,
        "title" => user.title,
        "email" => "valid@example.com",
        "organization" => user.organization,
        "photo_url" => nil}
    end
  end
end
