defmodule EmpiriApi.UserControllerTest do

  defmodule SharedContext do
    use ExUnit.CaseTemplate

    using do
      quote do
        use EmpiriApi.ConnCase
        alias EmpiriApi.User

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

        setup do
          conn = conn()
            |> put_req_header("accept", "application/json")
          {:ok, conn: conn}
        end
      end
    end
  end

  defmodule ShowContext do
    use SharedContext

    @action "SHOW"

    test "#{@action}: #{@context_desc[:existing_record]}, shows resource from db", %{conn: conn} do
      conn = conn |> put_req_header("authorization", "Bearer #{generate_auth_token(@valid_params)}")
      user = Repo.insert! Map.merge(%User{},@valid_attrs)
      conn = get conn, user_path(conn, :show)
      assert json_response(conn, 200)["data"] == %{"id" => user.id,
        "first_name" => user.first_name,
        "last_name" => user.last_name,
        "title" => user.title,
        "email" => user.email,
        "organization" => user.organization}
    end

    test "#{@action}: #{@context_desc[:existing_record]}, does not insert into db", %{conn: conn} do
      conn = conn |> put_req_header("authorization", "Bearer #{generate_auth_token(@valid_params)}")
      user = Repo.insert! Map.merge(%User{},@valid_attrs)
      count_fun = fn() -> Repo.all(from u in User, select: count(u.id)) |> List.first end
      user_count = count_fun.()
      get conn, user_path(conn, :show)

      assert count_fun.() == user_count
    end

    test "#{@action}: #{@context_desc[:new_record]},#{@context_desc[:invalid]}, does not insert into db", %{conn: conn} do
      conn = conn |> put_req_header("authorization", "Bearer #{generate_auth_token(@invalid_params)}")
      count_fun = fn() -> Repo.all(from u in User, select: count(u.id)) |> List.first end
      user_count = count_fun.()
      get conn, user_path(conn, :show)

      assert count_fun.() == user_count
    end

    test "#{@action}: #{@context_desc[:new_record]},#{@context_desc[:invalid]}, returns an error", %{conn: conn} do
      conn = conn |> put_req_header("authorization", "Bearer #{generate_auth_token(@invalid_params)}")
      conn = get conn, user_path(conn, :show)
      assert json_response(conn, 422)["errors"] != nil
    end

    test "#{@action}: #{@context_desc[:new_record]},#{@context_desc[:valid]}, inserts into db", %{conn: conn} do
      conn = conn |> put_req_header("authorization", "Bearer #{generate_auth_token(@valid_params)}")
      count_fun = fn() -> Repo.all(from u in User, select: count(u.id)) |> List.first end
      user_count = count_fun.()
      get conn, user_path(conn, :show)

      assert count_fun.() == user_count + 1
    end

    test "#{@action}: #{@context_desc[:new_record]},#{@context_desc[:valid]}, returns user data", %{conn: conn} do
      conn = conn |> put_req_header("authorization", "Bearer #{generate_auth_token(@valid_params)}")
      conn = get conn, user_path(conn, :show)
      assert json_response(conn, 200)["data"]["first_name"] == @valid_params[:given_name]

    end
  end

  defmodule UpdateContext do
    use SharedContext

    @action "UPDATE"

    setup do
      conn = conn |> put_req_header("authorization", "Bearer #{generate_auth_token(@valid_params)}")
      valid_attrs = Map.drop(@valid_attrs, [:auth_provider, :auth_id])
      {:ok, conn: conn, valid_attrs: valid_attrs}
    end

    test "#{@action}: resource not found", %{conn: conn, valid_attrs: valid_attrs} do
      conn = put conn, user_path(conn, :update, 77), user: valid_attrs
      assert json_response(conn, 404)["error"] == "Not Found"
    end

    test "#{@action}: resource found, data invalid", %{conn: conn, valid_attrs: valid_attrs} do
      user  = Repo.insert! Map.merge(%User{}, @valid_attrs)
      conn = put conn, user_path(conn, :update, user.id), user: %{email: "invalid-email-string"}
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "#{@action}: resource found, data is valid", %{conn: conn, valid_attrs: valid_attrs} do
      user  = Repo.insert! Map.merge(%User{}, @valid_attrs)
      conn = put conn, user_path(conn, :update, user.id), user: %{email: "valid@example.com"}
      assert json_response(conn, 200)["data"] == %{"id" => user.id,
        "first_name" => user.first_name,
        "last_name" => user.last_name,
        "title" => user.title,
        "email" => "valid@example.com",
        "organization" => user.organization}
    end
  end
end
