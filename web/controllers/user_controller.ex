defmodule EmpiriApi.UserController do
  use EmpiriApi.Web, :controller

  alias EmpiriApi.User

  plug :scrub_params, "user" when action in [:create, :update]
  plug :translate_token_claims

  def show(conn, _) do
    user = RepoExtensions.get_or_insert_by(User, %{auth_id: conn.user[:auth_id], auth_provider: conn.user[:auth_provider]}, conn.user)

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
    user = Repo.get!(User, id)
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

  defp translate_token_claims(conn, _) do
    joken_attrs = conn.assigns[:joken_claims]
    [auth_provider, auth_id] = String.split(joken_attrs["sub"], "|")
    Map.merge(conn, %{user: %{auth_provider: auth_provider, auth_id: auth_id,
                              email: joken_attrs["email"], first_name: joken_attrs["given_name"],
                              last_name: joken_attrs["family_name"], photo_url: joken_attrs["picture"]}})
  end
end
