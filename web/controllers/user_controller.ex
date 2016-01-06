defmodule EmpiriApi.UserController do
  use EmpiriApi.Web, :controller

  alias EmpiriApi.User

  plug :scrub_params, "user" when action in [:create, :update]
  plug AuthPlug
  plug :translate_token_claims

  def show(conn, _) do
    user = Repo.get_or_insert_by(User, %{auth_id: conn.user[:auth_id], auth_provider: conn.user[:auth_provider]}, conn.user)

    case user do
      {:ok, valid_user} ->
        render(conn, "show.json", user: valid_user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmpiriApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get(User, id)
    if user, do: authorize_and_update(conn, user, user_params), else: render_not_found(conn)
  end

  defp authorize_and_update(conn, user, user_params) do
    if user.auth_provider == conn.user[:auth_provider] && user.auth_id == conn.user[:auth_id] do
      update_and_render(conn, user, user_params)
    else
      render_unauthorized(conn)
    end
  end

  defp update_and_render(conn, user, user_params) do
    user = Repo.preload(user, :user_hypotheses)
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        render(conn, "show.json", user: user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmpiriApi.ChangesetView, "error.json", changeset: changeset)
    end
  end
end
