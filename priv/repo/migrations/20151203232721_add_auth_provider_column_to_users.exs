defmodule EmpiriApi.Repo.Migrations.AddAuthProviderColumnToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :auth_provider, :string
    end
  end
end
