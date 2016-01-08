defmodule EmpiriApi.HypothesisTest do
  use EmpiriApi.ModelCase

  alias EmpiriApi.Hypothesis

  @valid_attrs %{synopsis: "some content", title: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Hypothesis.changeset(%Hypothesis{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Hypothesis.changeset(%Hypothesis{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "defaults 'private' to true" do
    changeset = Hypothesis.changeset(%Hypothesis{}, @valid_attrs)
    hypo = Repo.insert!(changeset)

    assert hypo.private == true
  end

  test "has an association to users" do
    user_attrs = %{email: "pug@relaxation.com", first_name: "Pug",
                   last_name: "Jeremy", auth_id: "12345",
                   organization: "AKC", title: "Overlord",
                   auth_provider: "petco"}

    user = EmpiriApi.User.changeset(%EmpiriApi.User{}, user_attrs) |> Repo.insert!
    hypo = EmpiriApi.Hypothesis.changeset(%EmpiriApi.Hypothesis{}, %{title: "titulo"}) |> Repo.insert!
    Ecto.build_assoc(hypo, :user_hypotheses, user_id: user.id) |> Repo.insert!

    {:ok, hypo_users} = Repo.get(Hypothesis, hypo.id) |> Repo.preload(:users) |> Map.fetch(:users)

    assert Enum.member?(hypo_users, user)
  end

  test "#admins/1" do
    user1_attrs = %{email: "pug@relaxation.com", first_name: "Pug",
                   last_name: "Jeremy", auth_id: "12345",
                   organization: "AKC", title: "Overlord",
                   auth_provider: "petco"}

    user2_attrs = %{email: "buster@example.com", first_name: "Buster",
                   last_name: "Garcia", auth_id: "11112",
                   organization: "AKC", title: "Overlord",
                   auth_provider: "petco"}

    user1 = EmpiriApi.User.changeset(%EmpiriApi.User{}, user1_attrs) |> Repo.insert!
    user2 = EmpiriApi.User.changeset(%EmpiriApi.User{}, user2_attrs) |> Repo.insert!
    hypo = EmpiriApi.Hypothesis.changeset(%EmpiriApi.Hypothesis{}, %{title: "titulo"}) |> Repo.insert!
    Ecto.build_assoc(hypo, :user_hypotheses, user_id: user1.id) |> Repo.insert!
    Ecto.build_assoc(hypo, :user_hypotheses, user_id: user2.id, admin: true) |> Repo.insert!

    assert Hypothesis.admins(Repo.get(Hypothesis, hypo.id)) |> Enum.member?(user2)
    refute Hypothesis.admins(Repo.get(Hypothesis, hypo.id)) |> Enum.member?(user1)
  end
end
