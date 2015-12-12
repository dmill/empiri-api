defmodule EmpiriApi.Plugs.AuthPlugTest do

  use ExUnit.Case, async: true

  setup do {:ok, return_value: EmpiriApi.Plugs.AuthPlug.validate_auth_token} end

  test "returns a Joken.Token struct using the Poison JSON module", %{return_value: return_value} do
    assert return_value.json_module == Poison
  end

  test "returns a Joken.Token struct using the the app's client_secret", %{return_value: return_value} do
    assert return_value.signer.jwk["k"] == Application.get_env(:empiri_api, Auth0)[:client_secret]
  end

  test "returns a Joken.Token struct that validates the client_id", %{return_value: return_value} do
    assert return_value.validations["aud"].(Application.get_env(:empiri_api, Auth0)[:client_id])
  end
end