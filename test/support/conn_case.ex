defmodule EmpiriApi.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  imports other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate
  require Joken

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      alias EmpiriApi.Repo
      import Ecto.Model
      import Ecto.Query, only: [from: 2]

      import EmpiriApi.Router.Helpers

      # The default endpoint for testing
      @endpoint EmpiriApi.Endpoint

      def generate_auth_token() do
        {:ok, secret} = Base.url_decode64(Application.get_env(:empiri_api, Auth0)[:client_secret])
        %{client_id: Application.get_env(:empiri_api, Auth0)[:client_id]}
          |> Joken.token
          |> Joken.with_signer(Joken.hs256(secret))
          |> Joken.sign
          |> Joken.get_compact
      end
    end
  end

  setup tags do
    unless tags[:async] do
      Ecto.Adapters.SQL.restart_test_transaction(EmpiriApi.Repo, [])
    end

    :ok
  end
end
