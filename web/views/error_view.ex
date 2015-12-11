defmodule EmpiriApi.ErrorView do
  use EmpiriApi.Web, :view

  def render("404.json", _assigns) do
    %{error: "Not Found"}
  end

  def render("500.json", _assigns) do
    %{error: "Internal Server Error"}
  end

  def render("400.json", _assigns) do
    %{error: "Bad Request"}
  end

  def render("401.json", _assigns) do
    %{error: "Unauthorized"}
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render "500.json", assigns
  end
end
