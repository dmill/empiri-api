defmodule EmpiriApi.PublicationController do
  use EmpiriApi.Web, :controller

  alias EmpiriApi.Publication
  alias EmpiriApi.User

  plug AuthenticationPlug when action in [:create, :update, :delete]
  plug :translate_token_claims when action in [:create, :update, :delete]
  plug :scrub_params, "publication" when action in [:create, :update]

  def index(conn, params) do
    publications = Repo.all(from p in Publication,
                          where: [deleted: false, published: true],
                          offset: ^(params["offset"] || 0),
                          limit: ^(params["limit"] || 10),
                          order_by: [desc: p.id],
                          preload: [:users])

    render(conn, "index.json", publications: publications)
  end

  def create(conn, %{"publication" => publication_params}) do
    user = Repo.get_by!(User, auth_provider: conn.user[:auth_provider], auth_id: conn.user[:auth_id])
    changeset = Publication.changeset(%Publication{}, publication_params)

    case Repo.insert(changeset) do
      {:ok, publication} ->
        Ecto.build_assoc(publication, :user_publications, user_id: user.id, admin: true) |> Repo.insert

        conn
        |> put_status(:created)
        |> put_resp_header("location", publication_path(conn, :show, publication))
        |> render("show.json", publication: Repo.preload(publication, :users))
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmpiriApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    publication = Repo.get_by!(Publication, id: id, deleted: false) |> Repo.preload(:users)
    if !publication.published do
      authorize_user(conn, publication)
    else
      render(conn, "show.json", publication: publication)
    end
  end

  def update(conn, %{"id" => id, "publication" => publication_params}) do
    publication = Repo.get_by!(Publication, id: id, deleted: false) |> Repo.preload(:users)
    new_authorize_user(conn, publication, publication_params)
  end

  def delete(conn, %{"id" => id}) do
    publication = Repo.get_by!(Publication, id: id, deleted: false) |> Repo.preload(:users)
    new_authorize_user(conn, publication)
  end
###################### Private ################################
  defp authorize_user(conn, publication, params \\ nil) do
    conn = AuthenticationPlug.call(conn)

    if conn.halted do
      conn
    else
      conn |> translate_token_claims |> find_user_auth(publication, params)
    end
  end

  defp new_authorize_user(conn, publication, params \\ nil) do
    conn |> find_user_auth(publication, params)
  end

  defp find_user_auth(conn, publication, params) do
    users_auth_creds = publication.users |> Enum.map(fn(user) ->
                                            %{auth_provider: user.auth_provider, auth_id: user.auth_id} end)

    if Enum.member?(users_auth_creds, %{auth_provider: conn.user[:auth_provider], auth_id: conn.user[:auth_id]}) do
      perform_private_operation(conn.private[:phoenix_action], conn, publication, params)
    else
     render_unauthorized(conn)
    end
  end

  defp perform_private_operation(:show, conn, publication, _), do: render(conn, "show.json", publication: publication)

  defp perform_private_operation(:update, conn, publication, params) do
    if check_admin_status(conn, publication) do
      changeset = Publication.changeset(publication, params)

      case Repo.update(changeset) do
        {:ok, publication} ->
          render(conn, "show.json", publication: publication)
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(EmpiriApi.ChangesetView, "error.json", changeset: changeset)
      end
    else
      render_unauthorized(conn)
    end
  end

  defp perform_private_operation(:delete, conn, publication, _) do
    if check_admin_status(conn, publication) do
      Publication.changeset(publication, %{deleted: true}) |> Repo.update!
      send_resp(conn, :no_content, "")
    else
      render_unauthorized(conn)
    end
  end

  defp check_admin_status(conn, publication) do
    Publication.admins(publication) |> Enum.find(fn(user) ->
                                                user.auth_provider == conn.user[:auth_provider] &&
                                                user.auth_id == conn.user[:auth_id]
                                               end)
  end
end
