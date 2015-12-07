defmodule EmpiriApi.UserTest do
  use EmpiriApi.ModelCase

  alias EmpiriApi.User

  @valid_attrs   %{email: "pug@relaxation.com", first_name: "Pug",
                   last_name: "Jeremy", auth_id: "12345",
                   organization: "AKC", title: "Overlord",
                   auth_provider: "petco"}
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

  test "changeset with a non-unique auth_id, but different auth_provider" do
    User.changeset(%User{}, @valid_attrs) |> Repo.insert
    {result, _} = User.changeset(%User{}, %{@valid_attrs | auth_provider: "else"}) |> Repo.insert

    assert result == :ok
  end

  test "changeset with a non-unique auth_id and the same auth_provider" do
    User.changeset(%User{}, @valid_attrs) |> Repo.insert
    {result, errors} = User.changeset(%User{}, @valid_attrs) |> Repo.insert

    assert result == :error
  end
end
