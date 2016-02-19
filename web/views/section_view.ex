defmodule EmpiriApi.SectionView do
  use EmpiriApi.Web, :view

  def render("index.json", %{sections: sections}) do
    %{sections: render_many(sections, EmpiriApi.SectionView, "section.json")}
  end

  def render("show.json", %{section: section}) do
    %{section: render_one(section, EmpiriApi.SectionView, "section.json")}
  end

  def render("section.json", %{section: section}) do
    %{id: section.id,
      title: section.title,
      body: section.body,
      position: section.position,
      publication_id: section.publication_id}
  end
end