defmodule EmpiriApi.Repo.Migrations.CreateReview do
  use Ecto.Migration

  def change do
    create table(:reviews) do
      add :title, :string
      add :body, :text
      add :rating, :integer
      add :publication_id, references(:publications, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps
    end
    create index(:reviews, [:publication_id])
    create index(:reviews, [:user_id])

  end
end
