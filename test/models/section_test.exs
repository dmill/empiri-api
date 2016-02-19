defmodule EmpiriApi.SectionTest do
  use EmpiriApi.ModelCase

  alias EmpiriApi.Section

  @valid_attrs %{body: "some content", position: 42, title: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Section.changeset(%Section{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Section.changeset(%Section{}, @invalid_attrs)
    refute changeset.valid?
  end
end