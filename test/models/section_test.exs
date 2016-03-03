defmodule EmpiriApi.SectionTest do
  use EmpiriApi.ModelCase

  alias EmpiriApi.Section
  alias EmpiriApi.Repo
  alias EmpiriApi.Publication

  @valid_attrs %{body: "some content", position: 42, title: "some content"}
  @invalid_attrs %{body: 13}

  test "changeset with valid attributes" do
    changeset = Section.changeset(%Section{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    publication = Publication.changeset(%Publication{}, %{title: "yes"}) |> Repo.insert!
    changeset = Ecto.build_assoc(publication, :sections, %{}) |> Section.changeset(@invalid_attrs)
    refute changeset.valid?
  end
end
