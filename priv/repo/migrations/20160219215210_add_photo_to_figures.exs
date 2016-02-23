defmodule EmpiriApi.Repo.Migrations.AddPhotoToFigures do
  use Ecto.Migration

  def change do
    alter table(:figures) do
      add :photo, :string
    end
  end
end
