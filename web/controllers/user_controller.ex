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
    if user, do: update_and_render(conn, user, user_params), else: render_not_found(conn)
  end

  defp translate_token_claims(conn, _) do
    joken_attrs = conn.assigns[:joken_claims]
    [auth_provider, auth_id] = String.split(joken_attrs["sub"], "|")
    Map.merge(conn, %{user: %{auth_provider: auth_provider, auth_id: auth_id,
                              email: joken_attrs["email"], first_name: joken_attrs["given_name"],
                              last_name: joken_attrs["family_name"], photo_url: joken_attrs["picture"]}})
  end

  defp update_and_render(conn, user, user_params) do
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

  defp render_not_found(conn) do
    conn |> put_status(:not_found) |> render(EmpiriApi.ErrorView, "404.json")
  end
end
