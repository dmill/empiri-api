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
        @invalid_attrs %{}

        setup do
          conn = conn()
            |> put_req_header("accept", "application/json")
            |> put_req_header("authorization", "Bearer #{generate_auth_token(@valid_attrs)}")
          {:ok, conn: conn}
        end
      end
    end
  end

  defmodule ShowContext do
    use SharedContext

    @action "SHOW"

    test "#{@action}: #{@context_desc[:existing_record]}, shows resource from db", %{conn: conn} do
      user = Repo.insert! Map.merge(%User{},@valid_attrs)
      conn = get conn, user_path(conn, :show)
      assert json_response(conn, 200)["data"] == %{"id" => user.id,
        "first_name" => user.first_name,
        "last_name" => user.last_name,
        "title" => user.title,
        "email" => user.email,
        "organization" => user.organization}
    end

    test "#{@action}: #{@context_desc[:new_record]},#{@context_desc[:invalid]}, does not insert into db" do
    end

    test "#{@action}: #{@context_desc[:new_record]},#{@context_desc[:invalid]}, returns an error" do
    end

    test "#{@action}: #{@context_desc[:new_record]},#{@context_desc[:valid]}, inserts into db" do
    end

    test "#{@action}: #{@context_desc[:new_record]},#{@context_desc[:valid]}, returns user data" do
    end
  end

  # test "updates and renders chosen resource when data is valid", %{conn: conn} do
    # user = Repo.insert! %User{}
    # conn = put conn, user_path(conn, :update, user), user: @valid_attrs
    # assert json_response(conn, 200)["data"]["id"]
    # assert Repo.get_by(User, @valid_attrs)
  # end

  # test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    # user = Repo.insert! %User{}
    # conn = put conn, user_path(conn, :update, user), user: @invalid_attrs
    # assert json_response(conn, 422)["errors"] != %{}
  # end
end
