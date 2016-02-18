defmodule EmpiriApi.Repo.Migrations.ChangeSectionsIndexToPosition do
  use Ecto.Migration

  def change do
    alter table(:sections) do
      add :position, :integer
      remove :index
    end
  end
end
