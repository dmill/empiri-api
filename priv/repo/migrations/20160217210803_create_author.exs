defmodule EmpiriApi.Repo.Migrations.CreateAuthor do
  use Ecto.Migration

  def change do
    create table(:authors) do
      add :first_name, :string
      add :last_name, :string
      add :title, :string
      add :email, :string
      add :organization, :string
      add :publication_id, references(:publications, on_delete: :nothing)

      timestamps
    end
    create index(:authors, [:publication_id])

  end
end
