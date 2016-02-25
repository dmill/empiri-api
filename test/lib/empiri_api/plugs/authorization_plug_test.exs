defmodule EmpiriApi.Plugs.AuthorizationPlugTest do

  use ExUnit.Case, async: true
  use EmpiriApi.ConnCase

  alias EmpiriApi.Plugs.AuthorizationPlug
  alias EmpiriApi.Repo
  alias EmpiriApi.User
  alias EmpiriApi.Review
  alias EmpiriApi.Publication
  alias EmpiriApi.UserPublication
  alias EmpiriApi.Section

  setup do
    user = User.changeset(%User{}, %{email: "slug@gmail.com",
                                     auth_id: "1",
                                     auth_provider: "goog"}) |> Repo.insert!

    review = Ecto.build_assoc(user, :reviews, %{user_id: 2,
                                                title: "title",
                                                body: "body",
                                                rating: 1}) |> Repo.insert!

    publication = Publication.changeset(%Publication{}, %{title: "title"}) |> Repo.insert!
    user_pub = Ecto.build_assoc(publication, :user_publications, %{user_id: user.id})|> Repo.insert!
    section = Ecto.build_assoc(publication, :sections, %{title: "title", position: 0}) |> Repo.insert!

    on_exit fn ->
      Repo.delete!(section)
      Repo.delete!(review)
      Repo.delete!(user_pub)
      Repo.delete!(publication)
      Repo.delete!(user)
    end

    {:ok, user: user,
          review: review,
          publication: publication,
          user_pub: user_pub,
          section: section}
  end

  test "conn has no current_user", %{user: _user, review: review} do
    conn = conn()
            |> Map.put(:params, %{"id" => review.id})
            |> AuthorizationPlug.call(Review)

    assert conn.state == :sent
    assert conn.status == 401
  end

  test "resource does not exist" do
    assert_raise Ecto.NoResultsError, fn ->
      conn()
        |> Map.put(:params, %{"id" => 1})
        |> Map.merge(%{assigns: %{current_user: %User{id: 1}}})
        |> AuthorizationPlug.call(Review)
    end
  end

  test "user does not own resource", %{user: _user, review: review} do
    conn = conn()
            |> Map.put(:params, %{"id" => review.id})
            |> Map.merge(%{assigns: %{current_user: %User{id: 5}}})
            |> AuthorizationPlug.call(Review)

    assert conn.state == :sent
    assert conn.status == 401
  end

  test "user directly owns resource", %{user: user, review: review} do
    conn = conn()
            |> Map.put(:params, %{"id" => review.id})
            |> Map.merge(%{assigns: %{current_user: user}})
            |> AuthorizationPlug.call(Review)

    assert conn.resource == review
  end

  test "user owns resource through an association", %{user: user, publication: publication} do
    conn = conn()
            |> Map.put(:params, %{"id" => publication.id})
            |> Map.merge(%{assigns: %{current_user: user}})
            |> AuthorizationPlug.call(Publication, ownership_on_associated: EmpiriApi.UserPublication)

    assert conn.resource == publication
  end

  test "user should be an admin, but is not", %{user: user, publication: publication} do
    conn = conn()
            |> Map.put(:params, %{"id" => publication.id})
            |> Map.merge(%{assigns: %{current_user: user}})
            |> AuthorizationPlug.call(Publication, ownership_on_associated: EmpiriApi.UserPublication,
                                                   admin: true)

    assert conn.state == :sent
    assert conn.status == 401
  end

  test "user is an admin", %{user: user, publication: publication, user_pub: user_pub} do
    UserPublication.changeset(user_pub, %{admin: true}) |> Repo.update

    conn = conn()
            |> Map.put(:params, %{"id" => publication.id})
            |> Map.merge(%{assigns: %{current_user: user}})
            |> AuthorizationPlug.call(Publication, ownership_on_associated: UserPublication,
                                                   admin: true)

    assert conn.resource == publication
  end

  test "nested resource", %{user: user, publication: publication, user_pub: user_pub, section: section} do
    conn = conn()
            |> Map.put(:params, %{"id" => section.id, "publication_id" => publication.id})
            |> Map.merge(%{assigns: %{current_user: user}})
            |> AuthorizationPlug.call(Publication, ownership_on_associated: UserPublication,
                                                   param: "publication_id")

    assert conn.resource == publication
  end
end
