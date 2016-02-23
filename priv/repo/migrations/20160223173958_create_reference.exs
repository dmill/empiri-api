defmodule EmpiriApi.Repo.Migrations.CreateReference do
  use Ecto.Migration

  def change do
    create table(:references) do
      add :authors, :text
      add :title, :string
      add :link, :string
      add :publication_id, references(:publications, on_delete: :nothing)

      timestamps
    end
    create index(:references, [:publication_id])

  end
end
