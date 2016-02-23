defmodule EmpiriApi.ReferenceView do
  use EmpiriApi.Web, :view

  def render("index.json", %{references: references}) do
    %{references: render_many(references, EmpiriApi.ReferenceView, "reference.json")}
  end

  def render("show.json", %{reference: reference}) do
    %{reference: render_one(reference, EmpiriApi.ReferenceView, "reference.json")}
  end

  def render("reference.json", %{reference: reference}) do
    %{id: reference.id,
      authors: authors(reference),
      title: reference.title,
      link: reference.link,
      publication_id: reference.publication_id}
  end

  defp authors(reference) do
    reference.authors |> String.split(",")
  end
end
