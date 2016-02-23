defmodule EmpiriApi.FigureView do
  use EmpiriApi.Web, :view

  def render("index.json", %{figures: figures}) do
    %{figures: render_many(figures, EmpiriApi.FigureView, "figure.json")}
  end

  def render("show.json", %{figure: figure}) do
    %{figure: render_one(figure, EmpiriApi.FigureView, "figure.json")}
  end

  def render("figure.json", %{figure: figure}) do
    %{
      id: figure.id,
      caption: figure.caption,
      position: figure.position,
      title: figure.title,
      section_id: figure.section_id,
      photo_url: EmpiriApi.Figure.photo_url(figure)
    }
  end
end
