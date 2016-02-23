defmodule EmpiriApi.UserView do
  use EmpiriApi.Web, :view

  alias EmpiriApi.PublicationView
  alias EmpiriApi.ReviewView

  def render("index.json", %{users: users}) do
    %{users: render_many(users, EmpiriApi.UserView, "user.json")}
  end

  def render("show.json", %{user: user, publications: publications}) do
    %{user: render_one(user, EmpiriApi.UserView, "user.json") |>
      Map.merge(render_embedded(%{user: user, publications: publications}))}
  end

  def render("show.json", %{user: user}) do
    %{user: render_one(user, EmpiriApi.UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      title: user.title,
      email: user.email,
      organization: user.organization,
      photo_url: EmpiriApi.User.photo_url(user) || user.external_photo_url
    }
  end

  defp render_embedded(%{user: user, publications: publications}) do
    %{
      _embedded: PublicationView.render("basic_index.json", %{publications: publications})
                 |> Map.merge(ReviewView.render("user_index.json", %{reviews: user.reviews}))
    }
  end
end
