defmodule EmpiriApi.ReviewController do
  use EmpiriApi.Web, :controller

  alias EmpiriApi.Review
  alias EmpiriApi.Publication
  alias EmpiriApi.UserPublication

  plug AuthenticationPlug when action in [:create, :update, :delete]
  plug TranslateTokenClaimsPlug when action in [:create, :update, :delete]
  plug CurrentUserPlug when action in [:create, :update, :delete]
  plug AuthorizationPlug, %{resource_type: Review} when action in [:update, :delete]

  plug :scrub_params, "review" when action in [:create, :update]

  def index(conn, %{"publication_id" => publication_id}) do
    publication = Repo.get!(Publication, publication_id) |> Repo.preload([:reviews])
    render(conn, "index.json", reviews: publication.reviews)
  end

  def create(conn, %{"publication_id" => publication_id, "review" => review_params}) do
    attrs = review_params |> Map.put("user_id", conn.assigns[:current_user].id)
    publication = Repo.get!(Publication, publication_id)
    changeset = Ecto.build_assoc(publication, :reviews) |> Review.changeset(attrs)

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

  def update(conn, %{"publication_id" => _publication_id, "id" => id, "review" => review_params}) do
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
