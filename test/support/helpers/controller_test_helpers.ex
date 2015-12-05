defmodule EmpiriApi.ControllerTestHelpers do

  def generate_auth_token(claims \\ %{}) do
    {:ok, secret} = Base.url_decode64(Application.get_env(:empiri_api, Auth0)[:client_secret])
    %{aud: Application.get_env(:empiri_api, Auth0)[:client_id],
      sub: "#{claims[:auth_provider]}|#{claims[:auth_id]}",
      email: claims[:email],
      first_name: claims[:first_name],
      last_name: claims[:last_name]}
      |> Joken.token
      |> Joken.with_signer(Joken.hs256(secret))
      |> Joken.sign
      |> Joken.get_compact
  end
end