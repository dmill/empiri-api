defmodule EmpiriApi.Repo.Migrations.ChangeUsersPhotoUrlColumnToProfilePhoto do
  use Ecto.Migration

  def change do
    rename table(:users), :photo_url, to: :profile_photo
  end
end
