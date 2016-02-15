defmodule EmpiriApi.PublicationController do
  use EmpiriApi.Web, :controller

  alias EmpiriApi.Publication
  alias EmpiriApi.User

  plug AuthPlug when action in [:create]
  plug :translate_token_claims when action in [:create]
  plug :scrub_params, "publication" when action in [:create, :update]

  def show(conn, %{"id" => id}) do
    publication = Repo.get_by!(Publication, id: id, deleted: false) |> Repo.preload(:users)
    if !publication.published do
      authorize_user(conn, publication)
    else
      render(conn, "show.json", publication: publication)
    end
  end

###################### Private ################################
  defp authorize_user(conn, publication, params \\ nil) do
    conn = AuthPlug.call(conn)

    if conn.halted do
      conn
    else
      conn |> translate_token_claims |> find_user_auth(publication, params)
    end
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

  # defp perform_private_operation(:update, conn, hypothesis, params) do
    # if check_admin_status(conn, hypothesis) do
      # changeset = Hypothesis.changeset(hypothesis, params)
#
      # case Repo.update(changeset) do
        # {:ok, hypothesis} ->
          # render(conn, "show.json", hypothesis: hypothesis)
        # {:error, changeset} ->
          # conn
          # |> put_status(:unprocessable_entity)
          # |> render(EmpiriApi.ChangesetView, "error.json", changeset: changeset)
      # end
    # else
      # render_unauthorized(conn)
    # end
  # end

  # defp perform_private_operation(:delete, conn, hypothesis, _) do
    # if check_admin_status(conn, hypothesis) do
      # Hypothesis.changeset(hypothesis, %{deleted: true}) |> Repo.update!
      # send_resp(conn, :no_content, "")
    # else
      # render_unauthorized(conn)
    # end
  # end
end
