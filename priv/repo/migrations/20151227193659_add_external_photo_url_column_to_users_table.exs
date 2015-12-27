defmodule EmpiriApi.Repo.Migrations.AddExternalPhotoUrlColumnToUsersTable do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :external_photo_url, :string
    end
  end
end
