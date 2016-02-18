defmodule EmpiriApi.UserPhotosControllerTest do
  defmodule CreateContext do
    use EmpiriApi.ConnCase
    alias EmpiriApi.User
    import Mock

    @action "CREATE"

    @valid_attrs %{email: "pugs@gmail.com", first_name: "Pug", last_name: "Jeremy",
                   organization: "Harvard", title: "President",
                   auth_id: "12345", auth_provider: "petco"}

    @valid_params %{email: @valid_attrs[:email], given_name: @valid_attrs[:first_name],
                    family_name: @valid_attrs[:last_name], auth_id: @valid_attrs[:auth_id],
                    auth_provider: @valid_attrs[:auth_provider]}

    setup do
      conn = conn()
              |> put_req_header("authorization", "Bearer #{generate_auth_token(@valid_params)}")
      {:ok, conn: conn}
    end

    test "#{@action}: bad content-type", %{conn: conn} do
      connection = conn |> put_req_header("content-type", "application/json")
      conn = post connection, user_user_photos_path(connection, :create, 77), Poison.encode!(%{user: @valid_attrs})
      assert json_response(conn, 415)["error"] == "Unsupported Media Type"
    end

    test "#{@action}: user resource not found", %{conn: conn} do
      connection = conn |> put_req_header("content-type", "multipart/form-data")
      conn = post connection, user_user_photos_path(connection, :create, 77), photo: "thing"
      assert json_response(conn, 404)["error"] == "Not Found"
    end

    test "#{@action}: resource found, user is unauthorized", %{conn: conn} do
      second_user_attrs = %{email: "guy@gmail.com", first_name: "Pug", last_name: "Jeremy",
                            organization: "Harvard", title: "President",
                            auth_id: "1234567", auth_provider: "petco"}
      Repo.insert! Map.merge(%User{}, @valid_attrs)
      user2 = Repo.insert! Map.merge(%User{}, second_user_attrs)

      connection = conn |> put_req_header("content-type", "multipart/form-data")
      conn = post connection, user_user_photos_path(connection, :create, user2.id), photo: "thing"
      assert json_response(conn, 401)["error"] == "Unauthorized"
    end

    test "#{@action}: resource found, photo is invalid", %{conn: conn} do
      user = Repo.insert! Map.merge(%User{}, @valid_attrs)
      connection = conn |> put_req_header("content-type", "multipart/form-data")
      conn = post connection, user_user_photos_path(connection, :create, user.id), photo: "thing"

      assert json_response(conn, 422)["error"] != %{}
    end

    #Phoenix will send a 400 for this when the error is raised from scrub_params
    test "#{@action}: resource found, no photo sent", %{conn: conn} do
      user = Repo.insert! Map.merge(%User{}, @valid_attrs)
      connection = conn |> put_req_header("content-type", "multipart/form-data")

      assert_raise Phoenix.MissingParamError, fn ->
        post connection, user_user_photos_path(connection, :create, user.id), photo: nil
      end
    end

    test "#{@action}: resource found, photo is valid, error uploading to S3", %{conn: conn} do
      with_mock EmpiriApi.ProfilePhoto, [store: fn(_args) -> {:error, ["unauthorized"]} end] do
        user = Repo.insert! Map.merge(%User{}, @valid_attrs)
        {:ok, photo_path} = Plug.Upload.random_file("testing")
        photo = File.read(photo_path)
        connection = conn |> put_req_header("content-type", "multipart/form-data")
        conn = post connection, user_user_photos_path(connection, :create, user.id), photo: photo

        assert json_response(conn, 422)["error"] != %{}
      end
    end

    test "#{@action}: resource found, photo is valid, success uploading to S3", %{conn: conn} do
      with_mock EmpiriApi.ProfilePhoto, [:passthrough], [store: fn(_args) -> {:ok, "filename.png"} end] do
        user = Repo.insert! Map.merge(%User{}, @valid_attrs)
        {:ok, photo_path} = Plug.Upload.random_file("testing")
        photo = File.read(photo_path)
        connection = conn |> put_req_header("content-type", "multipart/form-data")
        conn = post connection, user_user_photos_path(connection, :create, user.id), photo: photo

        assert (json_response(conn, 200)["url"] |> String.length) != 0
      end

    end
  end
end
