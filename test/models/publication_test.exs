defmodule EmpiriApi.PublicationTest do
  use EmpiriApi.ModelCase

  alias EmpiriApi.Publication

  @valid_attrs %{abstract: "some content", deleted: true, published: true, title: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Publication.changeset(%Publication{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Publication.changeset(%Publication{}, @invalid_attrs)
    refute changeset.valid?
  end
end
