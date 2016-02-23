defmodule EmpiriApi.FigurePhotosController do
  use EmpiriApi.Web, :controller
  alias EmpiriApi.Figure

  plug :scrub_params, "photo" when action in [:create, :update]
  # plug AuthenticationPlug
  # plug :translate_token_claims

  def create(conn, %{"figure_id" => figure_id, "photo" => photo}) do
    figure = Repo.get!(Figure, figure_id)
    changeset = Figure.changeset(figure, %{photo: photo})

    case Repo.update(changeset) do
      {:ok, figure} ->
        json conn, %{url: EmpiriApi.Figure.photo_url(figure)}
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmpiriApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  # defp authorize_and_create(conn, user, photo) do
    # if user.auth_provider == conn.user[:auth_provider] && user.auth_id == conn.user[:auth_id] do
      # upload_and_render(conn, user, photo)
    # else
      # render_unauthorized(conn)
    # end
  # end
#
  # defp upload_and_render(conn, user, photo) do
    # user = Repo.preload(user, :user_hypotheses)
    # changeset = User.changeset(user, %{profile_photo: photo})
#
    # case Repo.update(changeset) do
      # {:ok, user} ->
        # json conn, %{url: EmpiriApi.User.photo_url(user)}
      # {:error, changeset} ->
        # conn
        # |> put_status(:unprocessable_entity)
        # |> render(EmpiriApi.ChangesetView, "error.json", changeset: changeset)
    # end
  # end
end
