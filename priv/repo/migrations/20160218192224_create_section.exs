defmodule EmpiriApi.Repo.Migrations.CreateSection do
  use Ecto.Migration

  def change do
    create table(:sections) do
      add :title, :string
      add :body, :text
      add :index, :integer
      add :publication_id, references(:publications, on_delete: :nothing)

      timestamps
    end
    create index(:sections, [:publication_id])

  end
end
