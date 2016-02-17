defmodule EmpiriApi.PublicationAuthorsController do
  use EmpiriApi.Web, :controller

  alias EmpiriApi.Publication
  alias EmpiriApi.User

  plug AuthPlug when action in [:create]
  plug :translate_token_claims when action in [:create]
  plug :scrub_params, "publication" when action in [:create, :update]

  def create(conn, %{"publication_id" => publication_id, "author" => author_params}) do

  end

  def update(conn, %{"publication_id" => publication_id, "id" => id, "author" => author_params}) do

  end

  def delete(conn, %{"publication_id" => publication_id, "id" => id, "author" => author_params}) do

  end

##################### Private ################################
  # defp authorize_user(conn, publication, params \\ nil) do
    # conn = AuthPlug.call(conn)
#
    # if conn.halted do
      # conn
    # else
      # conn |> translate_token_claims |> find_user_auth(publication, params)
    # end
  # end
#
  # defp find_user_auth(conn, publication, params) do
    # users_auth_creds = publication.users |> Enum.map(fn(user) ->
                                            # %{auth_provider: user.auth_provider, auth_id: user.auth_id} end)
#
    # if Enum.member?(users_auth_creds, %{auth_provider: conn.user[:auth_provider], auth_id: conn.user[:auth_id]}) do
      # perform_private_operation(conn.private[:phoenix_action], conn, publication, params)
    # else
     # render_unauthorized(conn)
    # end
  # end
#
  # defp perform_private_operation(:show, conn, publication, _), do: render(conn, "show.json", publication: publication)
#
  # defp perform_private_operation(:update, conn, publication, params) do
    # if check_admin_status(conn, publication) do
      # changeset = Publication.changeset(publication, params)
#
      # case Repo.update(changeset) do
        # {:ok, publication} ->
          # render(conn, "show.json", publication: publication)
        # {:error, changeset} ->
          # conn
          # |> put_status(:unprocessable_entity)
          # |> render(EmpiriApi.ChangesetView, "error.json", changeset: changeset)
      # end
    # else
      # render_unauthorized(conn)
    # end
  # end
#
  # defp perform_private_operation(:delete, conn, publication, _) do
    # if check_admin_status(conn, publication) do
      # Publication.changeset(publication, %{deleted: true}) |> Repo.update!
      # send_resp(conn, :no_content, "")
    # else
      # render_unauthorized(conn)
    # end
  # end
#
  # defp check_admin_status(conn, publication) do
    # Publication.admins(publication) |> Enum.find(fn(user) ->
                                                # user.auth_provider == conn.user[:auth_provider] &&
                                                # user.auth_id == conn.user[:auth_id]
                                               # end)
  # end
end
