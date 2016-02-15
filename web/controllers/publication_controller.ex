defmodule EmpiriApi.PublicationController do
  use EmpiriApi.Web, :controller

  alias EmpiriApi.Publication
  alias EmpiriApi.User

  plug AuthPlug when action in [:create]
  plug :translate_token_claims when action in [:create]
  plug :scrub_params, "publication" when action in [:create, :update]

  def index(conn, _params) do
    publications = Repo.all(Publication)
    render(conn, "index.json", publications: publications)
  end

  def create(conn, %{"publication" => publication_params}) do
    changeset = Publication.changeset(%Publication{}, publication_params)

    case Repo.insert(changeset) do
      {:ok, publication} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", publication_path(conn, :show, publication))
        |> render("show.json", publication: publication)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmpiriApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    publication = Repo.get!(Publication, id)
    render(conn, "show.json", publication: publication)
  end

  def update(conn, %{"id" => id, "publication" => publication_params}) do
    publication = Repo.get!(Publication, id)
    changeset = Publication.changeset(publication, publication_params)

    case Repo.update(changeset) do
      {:ok, publication} ->
        render(conn, "show.json", publication: publication)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmpiriApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    publication = Repo.get!(Publication, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(publication)

    send_resp(conn, :no_content, "")
  end
end
