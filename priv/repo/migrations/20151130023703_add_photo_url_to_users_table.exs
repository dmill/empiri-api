defmodule EmpiriApi.Repo.Migrations.AddPhotoUrlToUsersTable do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :photo_url, :string
    end
  end
end
