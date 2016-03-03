defmodule EmpiriApi.FigureTest do
  use EmpiriApi.ModelCase

  alias EmpiriApi.Figure
  alias EmpiriApi.Section
  alias EmpiriApi.Repo

  @valid_attrs %{caption: "some content", position: 42, title: "blah"}
  @invalid_attrs %{position: "string"}

  test "changeset with valid attributes" do
    changeset = Figure.changeset(%Figure{}, @valid_attrs)
    assert changeset.valid?
    assert changeset.changes[:position] == @valid_attrs[:position]
  end

  test "changeset with invalid attributes" do
    changeset = Figure.changeset(%Figure{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset with nil position and no existing figures" do
    section = Section.changeset(%Section{}, %{position: 4, title: "hi"}) |> Repo.insert!
    changeset = Ecto.build_assoc(section, :figures, %{}) |> Figure.changeset(%{})

    assert changeset.changes[:position] == 0
  end

  test "changeset with nil position and existing figures" do
    section = Section.changeset(%Section{}, %{position: 4, title: "hi"}) |> Repo.insert!
    prev_fig = Ecto.build_assoc(section, :figures, %{}) |> Figure.changeset(%{}) |> Repo.insert!
    changeset = Ecto.build_assoc(section, :figures, %{}) |> Figure.changeset(%{})

    assert changeset.changes[:position] == 1
  end

  test "existing figure with a position" do
    section = Section.changeset(%Section{}, %{position: 4, title: "hi"}) |> Repo.insert!
    fig = Ecto.build_assoc(section, :figures, %{position: 17}) |> Figure.changeset(%{}) |> Repo.insert!
    changeset = Figure.changeset(fig, %{caption: "hi"})

    refute changeset.changes[:position]
  end
end
