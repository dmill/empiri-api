defmodule EmpiriApi.ReferenceTest do
  use EmpiriApi.ModelCase

  alias EmpiriApi.Reference

  @valid_attrs %{authors: "some content", link: "some content", title: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Reference.changeset(%Reference{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Reference.changeset(%Reference{}, @invalid_attrs)
    refute changeset.valid?
  end
end
