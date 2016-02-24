defmodule EmpiriApi.Plugs.TranslateTokenClaimsPlugTest do

  use ExUnit.Case, async: true
  use EmpiriApi.ConnCase

  alias EmpiriApi.Plugs.TranslateTokenClaimsPlug

  test "conn has no 'joken_claims' key under 'assigns" do
    conn = TranslateTokenClaimsPlug.call(conn())

    assert conn.state == :sent
    assert conn.status == 401
  end

  test "conn has proper joken claims" do
    claims = %{joken_claims: %{"aud" => "32BAXvuzoMtbvsTUYcgwwqwKX0EZZgc7",
                               "email" => "test@gmail.com", "email_verified" => true,
                               "exp" => 1455232274, "family_name" => "Smith", "given_name" => "John",
                               "iat" => 1454433274, "iss" => "https://empiri.auth0.com/",
                               "picture" => "https://lh6.googleusercontent.com/photo.jpg",
                               "sub" => "google-oauth2|1"}}

    conn = conn() |> Map.merge(%{assigns: claims}) |> TranslateTokenClaimsPlug.call

    assert conn.user_attrs[:auth_provider] == "google-oauth2"
    assert conn.user_attrs[:auth_id] == "1"
  end
end
