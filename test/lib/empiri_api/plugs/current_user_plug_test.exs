defmodule EmpiriApi.Plugs.CurrentUserPlugTest do

  use ExUnit.Case, async: true
  use EmpiriApi.ConnCase

  alias EmpiriApi.Plugs.CurrentUserPlug
  alias EmpiriApi.User

  test "conn has no 'user_attrs'" do
    conn = CurrentUserPlug.call(conn())

    assert conn.state == :sent
    assert conn.status == 401
  end

  test "user does not exist" do
    conn = conn()
          |> Map.merge(%{user_attrs: %{ auth_provider: "google", auth_id: "1"}})
          |> CurrentUserPlug.call

    assert conn.state == :sent
    assert conn.status == 401
  end

  test "user exists" do
    user = Repo.insert!(%User{auth_provider: "google", auth_id: "1"})

    conn = conn()
          |> Map.merge(%{user_attrs: %{ auth_provider: "google", auth_id: "1"}})
          |> CurrentUserPlug.call

    assert conn.assigns[:current_user] == user
  end
end
