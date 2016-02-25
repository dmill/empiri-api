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
    authorize_user_show(user, conn)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get(User, id)
    if user, do: authorize_and_perform_action(conn, :update, user, user_params), else: render_not_found(conn)
  end

##############################Private#############################################
  defp authorize_user_show(user, conn) do
    if conn.req_headers |> Enum.find(fn(header) -> {type, _token} = header; type == "authorization" end) do
      token_check_conn = AuthenticationPlug.call(conn)

     if token_check_conn.halted do
        perform_unauthorized(:show, conn, user)
      else
        token_check_conn |> TranslateTokenClaimsPlug.call |> authorize_and_perform_action(:show, user, %{})
      end
    else
      perform_unauthorized(:show, conn, user)
    end
  end

  defp authorize_and_perform_action(conn, action, user, user_params) do
    if user.auth_provider == conn.user_attrs[:auth_provider] && user.auth_id == conn.user_attrs[:auth_id] do
      perform_action_and_render(action, conn, user, user_params)
    else
      perform_unauthorized(action, conn, user)
    end
  end

  defp perform_action_and_render(:show, conn, user, _user_params) do
    render(conn, "show.json", user: user, publications: user.publications)
  end

  defp perform_action_and_render(:update, conn, user, user_params) do
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

  defp perform_unauthorized(:update, conn, _user) do
    render_unauthorized(conn)
  end

  defp perform_unauthorized(:show, conn, user) do
    publications = user.publications |> Enum.filter(fn(pub) -> pub.published end)
    render(conn, "show.json", user: user, publications: publications)
  end
end
