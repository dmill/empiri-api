defmodule EmpiriApi.HypothesisController do
  # use EmpiriApi.Web, :controller
#
  # alias EmpiriApi.Hypothesis
  # alias EmpiriApi.User
#
  # plug AuthPlug when action in [:create]
  # plug :translate_token_claims when action in [:create]
  # plug :scrub_params, "hypothesis" when action in [:create, :update]
#
#
  # def index(conn, params) do
    # hypotheses = Repo.all(from h in Hypothesis,
                          # where: [deleted: false, private: false],
                          # offset: ^(params["offset"] || 0),
                          # limit: ^(params["limit"] || 10),
                          # order_by: [desc: h.id])
#
    # render(conn, "index.json", hypotheses: hypotheses)
  # end
#
  # def create(conn, %{"hypothesis" => hypothesis_params}) do
    # user = Repo.get_by!(User, auth_provider: conn.user[:auth_provider], auth_id: conn.user[:auth_id])
    # changeset = Hypothesis.changeset(%Hypothesis{}, hypothesis_params)
#
    # case Repo.insert(changeset) do
      # {:ok, hypothesis} ->
        # Ecto.build_assoc(hypothesis, :user_hypotheses, user_id: user.id, admin: true) |> Repo.insert
#
        # conn
        # |> put_status(:created)
        # |> put_resp_header("location", hypothesis_path(conn, :show, hypothesis))
        # |> render("show.json", hypothesis: hypothesis)
      # {:error, changeset} ->
        # conn
        # |> put_status(:unprocessable_entity)
        # |> render(EmpiriApi.ChangesetView, "error.json", changeset: changeset)
    # end
  # end
#
  # def show(conn, %{"id" => id}) do
    # hypothesis = Repo.get_by!(Hypothesis, id: id, deleted: false) |> Repo.preload(:users)
    # if hypothesis.private == true do
      # authorize_user(conn, hypothesis)
    # else
      # render(conn, "show.json", hypothesis: hypothesis)
    # end
  # end
#
  # def update(conn, %{"id" => id, "hypothesis" => hypothesis_params}) do
    # hypothesis = Repo.get_by!(Hypothesis, id: id, deleted: false) |> Repo.preload(:users)
    # authorize_user(conn, hypothesis, hypothesis_params)
  # end
#
  # def delete(conn, %{"id" => id}) do
    # hypothesis = Repo.get_by!(Hypothesis, id: id, deleted: false) |> Repo.preload(:users)
    # authorize_user(conn, hypothesis)
  # end
#
##################### Private ################################
#
  # defp perform_private_operation(:show, conn, hypothesis, _), do: render(conn, "show.json", hypothesis: hypothesis)
#
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
#
  # defp perform_private_operation(:delete, conn, hypothesis, _) do
    # if check_admin_status(conn, hypothesis) do
      # Hypothesis.changeset(hypothesis, %{deleted: true}) |> Repo.update!
      # send_resp(conn, :no_content, "")
    # else
      # render_unauthorized(conn)
    # end
  # end
#
  # defp check_admin_status(conn, hypothesis) do
    # Hypothesis.admins(hypothesis) |> Enum.find(fn(user) ->
                                                # user.auth_provider == conn.user[:auth_provider] &&
                                                # user.auth_id == conn.user[:auth_id]
                                               # end)
  # end
end
