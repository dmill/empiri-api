defmodule EmpiriApi.ReviewController do
  use EmpiriApi.Web, :controller

  alias EmpiriApi.Review
  alias EmpiriApi.Publication

  plug :scrub_params, "review" when action in [:create, :update]

  def index(conn, %{"publication_id" => publication_id}) do
    publication = Repo.get!(Publication, publication_id) |> Repo.preload([:reviews])
    render(conn, "index.json", reviews: publication.reviews)
  end

  def create(conn, %{"publication_id" => publication_id, "review" => review_params}) do
    publication = Repo.get!(Publication, publication_id)
    changeset = Ecto.build_assoc(publication, :reviews) |> Review.changeset(review_params)

    case Repo.insert(changeset) do
      {:ok, review} ->
        conn
        |> put_status(:created)
        |> render("show.json", review: review)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmpiriApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def update(conn, %{"publication_id" => publication_id, "id" => id, "review" => review_params}) do
    review = Repo.get!(Review, id)
    changeset = Review.changeset(review, review_params)

    case Repo.update(changeset) do
      {:ok, review} ->
        render(conn, "show.json", review: review)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmpiriApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    review = Repo.get!(Review, id)

    Repo.delete!(review)

    send_resp(conn, :no_content, "")
  end
end
