defmodule EmpiriApi.UserController do
  use EmpiriApi.Web, :controller

  alias EmpiriApi.User

  plug :scrub_params, "user" when action in [:update]
  plug AuthenticationPlug when action in [:login, :update]
  plug TranslateTokenClaimsPlug when action in [:login, :update]

  def login(conn, _) do
    user = Repo.get_or_insert_by(User, %{auth_id: conn.user_attrs[:auth_id], auth_provider: conn.user_attrs[:auth_provider]}, conn.user_attrs)

    case user do
      {:ok, valid_user} ->
        valid_user = valid_user |> Repo.preload([:publications, :reviews])
        render(conn, "show.json", user: valid_user, publications: valid_user.publications)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmpiriApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id) |> Repo.preload([:publications, :reviews])
    publications = user.publications |> Enum.filter(fn(pub) -> pub.published end)
    render(conn, "show.json", user: user, publications: publications)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get(User, id)
    if user, do: authorize_and_update(conn, user, user_params), else: render_not_found(conn)
  end

  defp authorize_and_update(conn, user, user_params) do
    if user.auth_provider == conn.user_attrs[:auth_provider] && user.auth_id == conn.user_attrs[:auth_id] do
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
