defmodule EmpiriApi.HypothesisController do
  use EmpiriApi.Web, :controller

  alias EmpiriApi.Hypothesis
  alias EmpiriApi.User

  plug AuthPlug when action in [:create]
  plug :translate_token_claims when action in [:create]
  plug :scrub_params, "hypothesis" when action in [:create, :update]


  # def index(conn, _params) do
    # hypotheses = Repo.all(Hypothesis)
    # render(conn, "index.json", hypotheses: hypotheses)
  # end

  def create(conn, %{"hypothesis" => hypothesis_params}) do
    user = Repo.get_by!(User, auth_provider: conn.user[:auth_provider], auth_id: conn.user[:auth_id])
    changeset = Hypothesis.changeset(%Hypothesis{}, hypothesis_params)

    case Repo.insert(changeset) do
      {:ok, hypothesis} ->
        Ecto.build_assoc(hypothesis, :user_hypotheses, user_id: user.id, admin: true) |> Repo.insert

        conn
        |> put_status(:created)
        |> put_resp_header("location", hypothesis_path(conn, :show, hypothesis))
        |> render("show.json", hypothesis: hypothesis)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmpiriApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    hypothesis = Repo.get!(Hypothesis, id) |> Repo.preload(:users)
    if hypothesis.private == true do
      authorize_user(conn, hypothesis)
    else
      render(conn, "show.json", hypothesis: hypothesis)
    end
  end

  def update(conn, %{"id" => id, "hypothesis" => hypothesis_params}) do
    hypothesis = Repo.get!(Hypothesis, id) |> Repo.preload(:users)
    authorize_user(conn, hypothesis, hypothesis_params)
  end

  def delete(conn, %{"id" => id}) do
    hypothesis = Repo.get!(Hypothesis, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(hypothesis)

    send_resp(conn, :no_content, "")
  end

  defp authorize_user(conn, hypothesis, params \\ nil) do
    conn = AuthPlug.call(conn)

    if conn.halted do
      conn
    else
      conn |> translate_token_claims |> find_user_auth(hypothesis, params)
    end
  end

  defp find_user_auth(conn, hypothesis, params) do
    users_auth_creds = hypothesis.users |> Enum.map(fn(user) ->
                                            %{auth_provider: user.auth_provider, auth_id: user.auth_id} end)

    if Enum.member?(users_auth_creds, %{auth_provider: conn.user[:auth_provider], auth_id: conn.user[:auth_id]}) do
      perform_private_operation(conn.private[:phoenix_action], conn, hypothesis, params)
    else
     render_unauthorized(conn)
    end
  end

  defp perform_private_operation(:show, conn, hypothesis, _), do: render(conn, "show.json", hypothesis: hypothesis)

  defp perform_private_operation(:update, conn, hypothesis, params) do
    if check_admin_status(conn, hypothesis) do
      changeset = Hypothesis.changeset(hypothesis, params)

      case Repo.update(changeset) do
        {:ok, hypothesis} ->
          render(conn, "show.json", hypothesis: hypothesis)
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(EmpiriApi.ChangesetView, "error.json", changeset: changeset)
      end
    else
      render_unauthorized(conn)
    end
  end

  defp check_admin_status(conn, hypothesis) do
    Hypothesis.admins(hypothesis) |> Enum.find(fn(user) ->
                                                user.auth_provider == conn.user[:auth_provider] &&
                                                user.auth_id == conn.user[:auth_id]
                                               end)
  end
end
