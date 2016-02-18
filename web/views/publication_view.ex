defmodule EmpiriApi.PublicationView do
  use EmpiriApi.Web, :view
  alias EmpiriApi.UserView
  alias EmpiriApi.AuthorView
  alias EmpiriApi.Publication

  def render("index.json", %{publications: publications}) do
    %{publications: render_many(publications, EmpiriApi.PublicationView, "abbreviated_publication.json")}
  end

  def render("show.json", %{publication: publication}) do
    %{publication: render_one(publication, EmpiriApi.PublicationView, "publication.json")}
  end

  def render("publication.json", %{publication: publication}) do
    base_publication(publication) |> Map.merge(render_embedded(publication))
  end

  def render("abbreviated_publication.json", %{publication: publication}) do
    base_publication(publication) |> Map.merge(render_abbrev_embedded(publication))
  end

  defp base_publication(publication) do
    %{
      id: publication.id,
      title: publication.title,
      abstract: publication.abstract,
      published: publication.published,
      first_author_id: publication.first_author_id,
      last_author_id: publication.last_author_id,
      admin_ids: admin_ids(publication)
    }
  end

  defp render_embedded(publication) do
    %{
      _embedded: UserView.render("index.json", %{users: publication.users}) |>
                 Map.merge(AuthorView.render("index.json", %{authors: publication.authors}))
    }
  end

  defp render_abbrev_embedded(publication) do
    %{
      _embedded: UserView.render("index.json", %{users: publication.users}) |>
                 Map.merge(AuthorView.render("index.json", %{authors: publication.authors}))
    }
  end

  defp admin_ids(publication) do
    publication |> Publication.admins |> Enum.map(fn(pub) -> pub.id end)
  end
end
