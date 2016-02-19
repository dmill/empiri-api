defmodule EmpiriApi.FigureTest do
  use EmpiriApi.ModelCase

  alias EmpiriApi.Figure

  @valid_attrs %{caption: "some content", position: 42, title: "blah"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Figure.changeset(%Figure{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Figure.changeset(%Figure{}, @invalid_attrs)
    refute changeset.valid?
  end
end
