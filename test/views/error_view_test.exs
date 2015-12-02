defmodule EmpiriApi.ErrorViewTest do
  use EmpiriApi.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.json" do
    assert render_to_string(EmpiriApi.ErrorView, "404.json", []) ==
         to_string Poison.Encoder.encode(%{error: "Not Found"}, [])
  end

  test "render 500.html" do
    assert render_to_string(EmpiriApi.ErrorView, "500.json", []) ==
          to_string Poison.Encoder.encode(%{error: "Internal Server Error"}, [])
  end

  test "render any other" do
    assert render_to_string(EmpiriApi.ErrorView, "505.json", []) ==
          to_string Poison.Encoder.encode(%{error: "Internal Server Error"}, [])
  end
end
