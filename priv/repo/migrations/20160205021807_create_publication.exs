defmodule EmpiriApi.Repo.Migrations.CreatePublication do
  use Ecto.Migration

  def change do
    create table(:publications) do
      add :title, :string
      add :abstract, :text
      add :published, :boolean, default: false
      add :deleted, :boolean, default: false

      timestamps
    end

  end
end
