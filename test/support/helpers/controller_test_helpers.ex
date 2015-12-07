defmodule EmpiriApi.ControllerTestHelpers do

  def generate_auth_token(claims \\ %{}) do
    {:ok, secret} = Base.url_decode64(Application.get_env(:empiri_api, Auth0)[:client_secret])
    %{aud: Application.get_env(:empiri_api, Auth0)[:client_id],
      sub: "#{claims[:auth_provider]}|#{claims[:auth_id]}",
      email: claims[:email],
      given_name: claims[:given_name],
      family_name: claims[:family_name]}
      |> Joken.token
      |> Joken.with_signer(Joken.hs256(secret))
      |> Joken.sign
      |> Joken.get_compact
  end
end