defmodule EmpiriApi.Repo.Migrations.AddFirstAndLastAuthorIdsToPublications do
  use Ecto.Migration

  def change do
    alter table(:publications) do
      add :first_author_id, :integer
      add :last_author_id, :integer
    end
  end
end
