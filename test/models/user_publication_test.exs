defmodule EmpiriApi.UserPublicationTest do
  use EmpiriApi.ModelCase

  alias EmpiriApi.UserPublication

  @valid_attrs %{admin: true}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = UserPublication.changeset(%UserPublication{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = UserPublication.changeset(%UserPublication{}, @invalid_attrs)
    refute changeset.valid?
  end
end
