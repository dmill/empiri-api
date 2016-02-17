defmodule EmpiriApi.PublicationView do
  use EmpiriApi.Web, :view
  alias EmpiriApi.UserView

  def render("index.json", %{publications: publications}) do
    %{publications: render_many(publications, EmpiriApi.PublicationView, "publication.json")}
  end

  def render("show.json", %{publication: publication}) do
    %{publication: render_one(publication, EmpiriApi.PublicationView, "publication.json")}
  end

  def render("publication.json", %{publication: publication}) do
    %{
      id: publication.id,
      title: publication.title,
      abstract: publication.abstract,
      published: publication.published
    } #|> Map.merge(render_embedded(publication))
  end

  defp render_embedded(publication) do
    %{
      _embedded: UserView.render("index.json", %{users: publication.users})
    }
  end
end
