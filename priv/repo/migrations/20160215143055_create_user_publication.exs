defmodule EmpiriApi.Repo.Migrations.CreateUserPublication do
  use Ecto.Migration

  def change do
    create table(:user_publications) do
      add :admin, :boolean, default: false
      add :user_id, references(:users, on_delete: :nothing)
      add :publication_id, references(:publications, on_delete: :nothing)

      timestamps
    end
    create index(:user_publications, [:user_id])
    create index(:user_publications, [:publication_id])

  end
end
