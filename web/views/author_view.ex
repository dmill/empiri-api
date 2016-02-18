defmodule EmpiriApi.AuthorView do
  use EmpiriApi.Web, :view

  def render("index.json", %{authors: authors}) do
    %{authors: render_many(authors, EmpiriApi.AuthorView, "author.json")}
  end

  def render("show.json", %{author: author}) do
    %{author: render_one(author, EmpiriApi.AuthorView, "author.json")}
  end

  def render("author.json", %{author: author}) do
    %{
      id: author.id,
      first_name: author.first_name,
      last_name: author.last_name,
      title: author.title,
      email: author.email,
      organization: author.organization
    }
  end
end
