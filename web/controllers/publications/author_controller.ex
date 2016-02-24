defmodule EmpiriApi.AuthorController do
  use EmpiriApi.Web, :controller

  alias EmpiriApi.Publication
  alias EmpiriApi.Author

  plug AuthenticationPlug when action in [:create, :update, :delete]
  plug TranslateTokenClaimsPlug when action in [:create]
  plug :scrub_params, "author" when action in [:create, :update]


  def create(conn, %{"publication_id" => publication_id, "author" => author_params}) do
    publication = Repo.get!(Publication, publication_id)
    author = Ecto.build_assoc(publication, :authors) |> Author.changeset(author_params)

    case Repo.insert(author) do
      {:ok, author} ->
        conn
        |> put_status(:created)
        |> render("show.json", author: author)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmpiriApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def update(conn, %{"publication_id" => publication_id, "id" => id, "author" => author_params}) do
    author = Repo.get!(Author, id)
    changeset = Author.changeset(author, author_params)

    case Repo.update(changeset) do
      {:ok, author} ->
        render(conn, "show.json", author: author)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmpiriApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"publication_id" => publication_id, "id" => id, "author" => author_params}) do
    author = Repo.get!(Author, id)
    Repo.delete!(author)
    send_resp(conn, :no_content, "")
  end
end
