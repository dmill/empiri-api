defmodule EmpiriApi.Repo.Migrations.ChangePublicationTitleToText do
  use Ecto.Migration

  def change do
    alter table(:publications) do
      modify :title, :text
    end
  end
end
