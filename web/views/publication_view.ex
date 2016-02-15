defmodule EmpiriApi.PublicationView do
  use EmpiriApi.Web, :view

  def render("index.json", %{publications: publications}) do
    %{data: render_many(publications, EmpiriApi.PublicationView, "publication.json")}
  end

  def render("show.json", %{publication: publication}) do
    %{data: render_one(publication, EmpiriApi.PublicationView, "publication.json")}
  end

  def render("publication.json", %{publication: publication}) do
    %{id: publication.id,
      title: publication.title,
      abstract: publication.abstract,
      published: publication.published,
      deleted: publication.deleted}
  end
end
