defmodule EmpiriApi.PublicationTest do
  use EmpiriApi.ModelCase

  alias EmpiriApi.Publication

  @valid_attrs %{title: "some content", first_author_id: 1, last_author_id: 2}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Publication.changeset(%Publication{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Publication.changeset(%Publication{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "defaults 'published' to false" do
    changeset = Publication.changeset(%Publication{}, @valid_attrs)
    pub = Repo.insert!(changeset)

    assert pub.published == false
  end

  test "has an association to users" do
    user_attrs = %{email: "pug@relaxation.com", first_name: "Pug",
                   last_name: "Jeremy", auth_id: "12345",
                   organization: "AKC", title: "Overlord",
                   auth_provider: "petco"}

    user = EmpiriApi.User.changeset(%EmpiriApi.User{}, user_attrs) |> Repo.insert!
    pub = EmpiriApi.Publication.changeset(%EmpiriApi.Publication{}, %{title: "titulo"}) |> Repo.insert!
    Ecto.build_assoc(pub, :user_publications, user_id: user.id) |> Repo.insert!

    {:ok, pub_users} = Repo.get(Publication, pub.id) |> Repo.preload(:users) |> Map.fetch(:users)

    assert Enum.member?(pub_users, user)
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
    pub = EmpiriApi.Publication.changeset(%EmpiriApi.Publication{}, %{title: "titulo"}) |> Repo.insert!
    Ecto.build_assoc(pub, :user_publications, user_id: user1.id) |> Repo.insert!
    Ecto.build_assoc(pub, :user_publications, user_id: user2.id, admin: true) |> Repo.insert!

    assert Publication.admins(Repo.get(Publication, pub.id)) |> Enum.member?(user2)
    refute Publication.admins(Repo.get(Publication, pub.id)) |> Enum.member?(user1)
  end
end
