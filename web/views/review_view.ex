defmodule EmpiriApi.ReviewView do
  use EmpiriApi.Web, :view

  alias EmpiriApi.Repo
  alias EmpiriApi.UserView
  alias EmpiriApi.PublicationView

  def render("index.json", %{reviews: reviews}) do
    %{reviews: render_many(reviews, EmpiriApi.ReviewView, "review.json")}
  end

  def render("user_index.json", %{reviews: reviews}) do
    %{reviews: render_many(reviews, EmpiriApi.ReviewView, "user_review.json")}
  end
  def render("show.json", %{review: review}) do
    %{review: render_one(review, EmpiriApi.ReviewView, "review.json")}
  end

  def render("review.json", %{review: review}) do
    %{
      id: review.id,
      title: review.title,
      body: review.body,
      rating: review.rating,
      publication_id: review.publication_id,
      updated_at: review.updated_at
    } |> Map.merge(render_embedded_user(review |> Repo.preload([:user])))
  end

  def render("user_review.json", %{review: review}) do
    %{
      id: review.id,
      title: review.title,
      body: review.body,
      rating: review.rating,
      publication_id: review.publication_id
    } |> Map.merge(render_embedded_publication(review |> Repo.preload([:publication])))
  end

  defp render_embedded_user(review) do
    %{
      _embedded: UserView.render("show.json", %{user: review.user}) |> Map.merge(author(review))
    }
  end

  defp render_embedded_publication(review) do
    %{
      _embedded: PublicationView.render("abbreviated_publication.json", %{publication: review.publication |> Repo.preload([:users, :authors])})
                  |> Map.merge(author(review))
    }
  end

  defp author(review) do
    publication = (review |> Repo.preload([:publication])).publication
    author = (publication |> Repo.preload([:users])).users |> List.first

    %{ author: UserView.render("user.json", %{user: author}) }
  end
end
