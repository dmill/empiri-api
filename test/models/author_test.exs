defmodule EmpiriApi.AuthorTest do
  use EmpiriApi.ModelCase

  alias EmpiriApi.Author

  @valid_attrs %{email: "some@content.com", first_name: "some content", last_name: "some content", organization: "some content", title: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Author.changeset(%Author{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Author.changeset(%Author{}, @invalid_attrs)
    refute changeset.valid?
  end
end
