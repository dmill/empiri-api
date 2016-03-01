defmodule EmpiriApi.FigurePhotosControllerTest do
  defmodule CreateContext do
    use EmpiriApi.ConnCase
    alias EmpiriApi.User
    alias EmpiriApi.Publication
    import Mock

    @action "CREATE"

    @valid_attrs %{email: "pugs@gmail.com", first_name: "Pug", last_name: "Jeremy",
                   organization: "Harvard", title: "President",
                   auth_id: "12345", auth_provider: "petco"}

    @valid_params %{email: @valid_attrs[:email], given_name: @valid_attrs[:first_name],
                    family_name: @valid_attrs[:last_name], auth_id: @valid_attrs[:auth_id],
                    auth_provider: @valid_attrs[:auth_provider]}

    setup do
      user = User.changeset(%User{}, @valid_attrs) |> Repo.insert!

      publication = Publication.changeset(%Publication{}, %{title: "some content", last_author_id: 1, first_author_id: 2})
                    |> Repo.insert!

      user_pub = Ecto.build_assoc(publication, :user_publications, user_id: user.id, admin: true)
                 |> Repo.insert!

      section = Ecto.build_assoc(publication, :sections, %{position: 0})
                  |> Repo.insert!

      {:ok, conn: conn(), user: user, publication: publication, user_pub: user_pub, section: section}
    end

    test "#{@action}: bad content-type", %{conn: conn} do
      connection = conn |> put_req_header("content-type", "application/json")
      conn = post connection, "/publications/12/sections/13/photos", Poison.encode!(%{user: @valid_attrs})
      assert json_response(conn, 415)["error"] == "Unsupported Media Type"
    end

    test "#{@action}: section resource not found", %{conn: conn} do
      connection = conn
                    |> put_req_header("content-type", "multipart/form-data")
                    |> put_req_header("authorization", "Bearer #{generate_auth_token(@valid_params)}")


      assert_raise Ecto.NoResultsError, fn ->
        post connection, "/publications/12/sections/13/photos", photo: "thing"
      end
    end

    test "#{@action}: no auth header" do
      connection = conn
                    |> put_req_header("content-type", "multipart/form-data")
                    |> post("/publications/12/sections/13/photos", photo: "thing")

      assert json_response(connection, 401)["error"] == "unauthorized"
    end

    test "#{@action}: resource found, user is not found", %{conn: conn} do
      connection = conn
                    |> put_req_header("content-type", "multipart/form-data")
                    |> put_req_header("authorization", "Bearer #{generate_auth_token(auth_id: 5567)}")
                    |> post("/publications/12/sections/13/photos", photo: "thing")

      assert json_response(connection, 401)["error"] == "Unauthorized"
    end

    test "#{@action}: resource found, user is unauthorized", %{conn: conn, publication: publication, section: section} do
      attrs = @valid_attrs |> Map.merge(%{auth_id: "55789", auth_provider: "linkedin"})
      User.changeset(%User{}, attrs) |> Repo.insert!
      connection = conn
                    |> put_req_header("content-type", "multipart/form-data")
                    |> put_req_header("authorization", "Bearer #{generate_auth_token(attrs)}")
                    |> post("/publications/#{publication.id}/sections/#{section.id}/photos", photo: "thing")

      assert json_response(connection, 401)["error"] == "Unauthorized"
    end

    test "#{@action}: resource found, photo is invalid", %{conn: conn, user: _user, publication: publication, section: section} do
      connection = conn
                    |> put_req_header("content-type", "multipart/form-data")
                    |> put_req_header("authorization", "Bearer #{generate_auth_token(@valid_params)}")
                    |> post("/publications/#{publication.id}/sections/#{section.id}/photos", photo: "thing")

      assert json_response(connection, 422)["error"] != %{}
    end

    test "#{@action}: resource found, photo is valid, error uploading to S3", %{conn: conn, user: _user, publication: publication, section: section} do
      with_mock EmpiriApi.FigurePhoto, [store: fn(_args) -> {:error, ["unauthorized"]} end] do
      {:ok, photo_path} = Plug.Upload.random_file("testing")
      photo = File.read(photo_path)

      connection = conn
                    |> put_req_header("content-type", "multipart/form-data")
                    |> put_req_header("authorization", "Bearer #{generate_auth_token(@valid_params)}")
                    |> post("/publications/#{publication.id}/sections/#{section.id}/photos", photo: photo)

        assert json_response(connection, 422)["error"] != %{}
      end
    end

    test "#{@action}: resource found, photo is valid, success uploading to S3", %{conn: conn, user: _user, publication: publication, section: section} do
      with_mock EmpiriApi.FigurePhoto, [:passthrough], [store: fn(_args) -> {:ok, "filename.png"} end] do
        {:ok, photo_path} = Plug.Upload.random_file("testing")

        photo = File.read(photo_path)
              connection = conn
                    |> put_req_header("content-type", "multipart/form-data")
                    |> put_req_header("authorization", "Bearer #{generate_auth_token(@valid_params)}")
                    |> post("/publications/#{publication.id}/sections/#{section.id}/photos", photo: photo)

        assert json_response(connection, 200)["figure"]["photo_url"]
      end
    end
  end

  defmodule UpdateContext do
   use EmpiriApi.ConnCase
    alias EmpiriApi.User
    alias EmpiriApi.Publication
    import Mock

    @action "UPDATE"

    @valid_attrs %{email: "pugs@gmail.com", first_name: "Pug", last_name: "Jeremy",
                   organization: "Harvard", title: "President",
                   auth_id: "12345", auth_provider: "petco"}

    @valid_params %{email: @valid_attrs[:email], given_name: @valid_attrs[:first_name],
                    family_name: @valid_attrs[:last_name], auth_id: @valid_attrs[:auth_id],
                    auth_provider: @valid_attrs[:auth_provider]}

    setup do
      user = User.changeset(%User{}, @valid_attrs) |> Repo.insert!

      publication = Publication.changeset(%Publication{}, %{title: "some content", last_author_id: 1, first_author_id: 2})
                    |> Repo.insert!

      user_pub = Ecto.build_assoc(publication, :user_publications, user_id: user.id, admin: true)
                 |> Repo.insert!

      section = Ecto.build_assoc(publication, :sections, %{position: 0})
                  |> Repo.insert!

      figure = Ecto.build_assoc(section, :figures, %{title: "figure"})
                |> Repo.insert!
      {:ok, conn: conn(), user: user, publication: publication, user_pub: user_pub, section: section, figure: figure}
    end

    test "#{@action}: bad content-type", %{conn: conn} do
      connection = conn |> put_req_header("content-type", "application/json")
      conn = put connection, "/publications/12/sections/13/figures/6/photos", Poison.encode!(%{user: @valid_attrs})
      assert json_response(conn, 415)["error"] == "Unsupported Media Type"
    end

    test "#{@action}: figure resource not found", %{conn: conn, publication: publication, section: section, figure: _figure} do
      connection = conn
                    |> put_req_header("content-type", "multipart/form-data")
                    |> put_req_header("authorization", "Bearer #{generate_auth_token(@valid_params)}")


      assert_raise Ecto.NoResultsError, fn ->
        put connection, "/publications/#{publication.id}/sections/#{section.id}/figures/7892/photos", photo: "thing"
      end
    end

    test "#{@action}: no auth header" do
      connection = conn
                    |> put_req_header("content-type", "multipart/form-data")
                    |> put("/publications/12/sections/13/figures/6/photos", photo: "thing")

      assert json_response(connection, 401)["error"] == "unauthorized"
    end

    test "#{@action}: resource found, user is not found", %{conn: conn, publication: publication, section: section, figure: figure} do
      connection = conn
                    |> put_req_header("content-type", "multipart/form-data")
                    |> put_req_header("authorization", "Bearer #{generate_auth_token(auth_id: 5567)}")
                    |> put("/publications/#{publication.id}/sections/#{section.id}/figures/#{figure.id}/photos", photo: "thing")

      assert json_response(connection, 401)["error"] == "Unauthorized"
    end

    test "#{@action}: resource found, user is unauthorized", %{conn: conn, publication: publication, section: section, figure: figure} do
      attrs = @valid_attrs |> Map.merge(%{auth_id: "55789", auth_provider: "linkedin"})
      User.changeset(%User{}, attrs) |> Repo.insert!
      connection = conn
                    |> put_req_header("content-type", "multipart/form-data")
                    |> put_req_header("authorization", "Bearer #{generate_auth_token(attrs)}")
                    |> put("/publications/#{publication.id}/sections/#{section.id}/figures/#{figure.id}/photos", photo: "thing")

      assert json_response(connection, 401)["error"] == "Unauthorized"
    end

    test "#{@action}: resource found, photo is invalid", %{conn: conn, publication: publication, section: section, figure: figure} do
      connection = conn
                    |> put_req_header("content-type", "multipart/form-data")
                    |> put_req_header("authorization", "Bearer #{generate_auth_token(@valid_params)}")
                    |> put("/publications/#{publication.id}/sections/#{section.id}/figures/#{figure.id}/photos", photo: "thing")

      assert json_response(connection, 422)["error"] != %{}
    end

    test "#{@action}: resource found, photo is valid, error uploading to S3", %{conn: conn, publication: publication, section: section, figure: figure} do
      with_mock EmpiriApi.FigurePhoto, [store: fn(_args) -> {:error, ["unauthorized"]} end] do
      {:ok, photo_path} = Plug.Upload.random_file("testing")
      photo = File.read(photo_path)

      connection = conn
                    |> put_req_header("content-type", "multipart/form-data")
                    |> put_req_header("authorization", "Bearer #{generate_auth_token(@valid_params)}")
                    |> put("/publications/#{publication.id}/sections/#{section.id}/figures/#{figure.id}/photos", photo: photo)

        assert json_response(connection, 422)["error"] != %{}
      end
    end

    test "#{@action}: resource found, photo is valid, success uploading to S3", %{conn: conn, publication: publication, section: section, figure: figure} do
      with_mock EmpiriApi.FigurePhoto, [:passthrough], [store: fn(_args) -> {:ok, "filename.png"} end] do
        {:ok, photo_path} = Plug.Upload.random_file("testing")

        photo = File.read(photo_path)
              connection = conn
                    |> put_req_header("content-type", "multipart/form-data")
                    |> put_req_header("authorization", "Bearer #{generate_auth_token(@valid_params)}")
                    |> put("/publications/#{publication.id}/sections/#{section.id}/figures/#{figure.id}/photos", photo: photo)

        assert json_response(connection, 200)["figure"]["photo_url"]
      end
    end
  end
end
