defmodule EmpiriApi.Repo.Migrations.AddAuthIdAndAuthProviderToUsersTable do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :auth_id, :integer
      add :auth_provider, :string
    end
  end
end
