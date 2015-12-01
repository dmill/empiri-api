defmodule EmpiriApi.Repo.Migrations.RemoveUsersAuthProviderAndChangeAuthIdToVarchar do
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify :auth_id, :varchar
      remove :auth_provider
    end
  end
end
