defmodule EmpiriApi.Repo.Migrations.AddTitleToFigures do
  use Ecto.Migration

  def change do
    alter table(:figures) do
      add :title, :string
    end
  end
end
