defmodule EmpiriApi.UserPhotosController do
  use EmpiriApi.Web, :controller
  alias EmpiriApi.User

  plug :scrub_params, "photo" when action in [:create, :update]
  plug AuthenticationPlug
  plug TranslateTokenClaimsPlug

  def create(conn, %{"user_id" => user_id, "photo" => photo}) do
    user = Repo.get(User, user_id)
    if user, do: authorize_and_create(conn, user, photo), else: render_not_found(conn)
  end

  defp authorize_and_create(conn, user, photo) do
    if user.auth_provider == conn.user_attrs[:auth_provider] && user.auth_id == conn.user_attrs[:auth_id] do
      upload_and_render(conn, user, photo)
    else
      render_unauthorized(conn)
    end
  end

  defp upload_and_render(conn, user, photo) do
    user = Repo.preload(user, :user_hypotheses)
    changeset = User.changeset(user, %{profile_photo: photo})

    case Repo.update(changeset) do
      {:ok, user} ->
        json conn, %{url: EmpiriApi.User.photo_url(user)}
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmpiriApi.ChangesetView, "error.json", changeset: changeset)
    end
  end
end
