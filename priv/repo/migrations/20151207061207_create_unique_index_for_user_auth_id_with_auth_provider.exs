defmodule EmpiriApi.Repo.Migrations.CreateUniqueIndexForUserAuthIdWithAuthProvider do
  use Ecto.Migration

  def change do
    create unique_index(:users, [:auth_id, :auth_provider])
  end
end
