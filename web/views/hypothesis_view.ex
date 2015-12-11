defmodule EmpiriApi.HypothesisView do
  use EmpiriApi.Web, :view

  def render("index.json", %{hypotheses: hypotheses}) do
    %{data: render_many(hypotheses, EmpiriApi.HypothesisView, "hypothesis.json")}
  end

  def render("show.json", %{hypothesis: hypothesis}) do
    %{data: render_one(hypothesis, EmpiriApi.HypothesisView, "hypothesis.json")}
  end

  def render("hypothesis.json", %{hypothesis: hypothesis}) do
    %{id: hypothesis.id,
      title: hypothesis.title,
      synopsis: hypothesis.synopsis}
  end
end
