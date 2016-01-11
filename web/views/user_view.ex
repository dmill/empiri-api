defmodule EmpiriApi.UserView do
  use EmpiriApi.Web, :view

  def render("index.json", %{users: users}) do
    %{data: render_many(users, EmpiriApi.UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, EmpiriApi.UserView, "user.json")}
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
end
