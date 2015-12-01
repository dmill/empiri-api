defmodule EmpiriApi.UserTest do
  use EmpiriApi.ModelCase

  alias EmpiriApi.User

  @valid_attrs   %{email: "pug@relaxation.com", first_name: "Pug",
                   last_name: "Jeremy", auth_id: "something|longnumber",
                   organization: "AKC", title: "Overlord"}
  @empty_attrs   %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with empty attributes" do
    changeset = User.changeset(%User{}, @empty_attrs)
    refute changeset.valid?
  end

  test "changeset with an invalid email" do
    changeset = User.changeset(%User{}, Map.drop(@valid_attrs, [:email]))
    refute changeset.valid?
  end
end
