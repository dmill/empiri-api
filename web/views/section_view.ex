defmodule EmpiriApi.SectionView do
  use EmpiriApi.Web, :view

  def render("index.json", %{sections: sections}) do
    %{data: render_many(sections, EmpiriApi.SectionView, "section.json")}
  end

  def render("show.json", %{section: section}) do
    %{data: render_one(section, EmpiriApi.SectionView, "section.json")}
  end

  def render("section.json", %{section: section}) do
    %{id: section.id,
      title: section.title,
      body: section.body,
      index: section.index,
      publication_id: section.publication_id}
  end
end
