defmodule EmpiriApi.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :first_name, :string
      add :last_name, :string
      add :title, :string
      add :email, :string
      add :organization, :string

      timestamps
    end

  end
end
