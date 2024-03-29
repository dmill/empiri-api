defmodule EmpiriApi.PublicationController do
  use EmpiriApi.Web, :controller

  alias EmpiriApi.Publication
  alias EmpiriApi.UserPublication
  alias EmpiriApi.User

  plug AuthenticationPlug when action in [:create, :update, :delete]
  plug TranslateTokenClaimsPlug when action in [:create, :update, :delete]
  plug CurrentUserPlug when action in [:create, :update, :delete]
  plug AuthorizationPlug, %{resource_type: Publication,
                            ownership_on_associated: UserPublication,
                            admin: true} when action in [:update, :delete]
  plug :scrub_params, "publication" when action in [:create, :update]

  def index(conn, params) do
    publications = Repo.all(from p in Publication,
                          where: [deleted: false, published: true],
                          offset: ^(params["offset"] || 0),
                          limit: ^(params["limit"] || 10),
                          order_by: [desc: p.id],
                          preload: [:users, :authors])

    render(conn, "index.json", publications: publications)
  end

  def create(conn, %{"publication" => publication_params}) do
    user = conn.assigns[:current_user]
    changeset = Publication.changeset(%Publication{}, publication_params)

    case Repo.insert(changeset) do
      {:ok, publication} ->
        Ecto.build_assoc(publication, :user_publications, user_id: user.id, admin: true) |> Repo.insert

        conn
        |> put_status(:created)
        |> put_resp_header("location", publication_path(conn, :show, publication))
        |> render("show.json", publication: Repo.preload(publication, [:users, :authors, :sections, :references]))
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmpiriApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    publication = Repo.get_by!(Publication, id: id, deleted: false) |> Repo.preload([:users, :authors, :sections, :references, :reviews])
    if !publication.published do
      authorize_unpublished_show(conn, publication)
    else
      render(conn, "show.json", publication: publication)
    end
  end

  def update(conn, %{"id" => id, "publication" => publication_params}) do
    publication = conn.resource |> Repo.preload([:users, :authors, :sections, :references])

    if publication.deleted do
      render_not_found(conn)
    else
      changeset = Publication.changeset(publication, publication_params)

      case Repo.update(changeset) do
        {:ok, publication} ->
          render(conn, "show.json", publication: publication)
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(EmpiriApi.ChangesetView, "error.json", changeset: changeset)
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    publication = conn.resource |> Repo.preload([:users, :authors, :sections, :references])

    if publication.deleted do
      render_not_found(conn)
    else
      Publication.changeset(publication, %{deleted: true}) |> Repo.update!
      send_resp(conn, :no_content, "")
    end
  end
###################### Private ################################
  defp authorize_unpublished_show(conn, publication, params \\ nil) do
    conn = AuthenticationPlug.call(conn)

    if conn.halted do
      conn
    else
      conn |> TranslateTokenClaimsPlug.call |> find_user_auth(publication, params)
    end
  end

  defp find_user_auth(conn, publication, params) do
    users_auth_creds = publication.users |> Enum.map(fn(user) ->
                                            %{auth_provider: user.auth_provider, auth_id: user.auth_id} end)

    if Enum.member?(users_auth_creds, %{auth_provider: conn.user_attrs[:auth_provider], auth_id: conn.user_attrs[:auth_id]}) do
      render(conn, "show.json", publication: publication)
    else
     render_unauthorized(conn)
    end
  end
end
