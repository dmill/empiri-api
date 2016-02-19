defmodule EmpiriApi.Repo.Migrations.CreateFigure do
  use Ecto.Migration

  def change do
    create table(:figures) do
      add :caption, :text
      add :position, :integer
      add :section_id, references(:sections, on_delete: :nothing)

      timestamps
    end
    create index(:figures, [:section_id])

  end
end
