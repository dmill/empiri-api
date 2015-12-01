defmodule EmpiriApi.Repo.Migrations.ChangeUsersAuthIdToBigint do
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify :auth_id, :bigint
    end
  end
end
