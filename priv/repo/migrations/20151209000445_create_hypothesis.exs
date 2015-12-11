defmodule EmpiriApi.Repo.Migrations.CreateHypothesis do
  use Ecto.Migration

  def change do
    create table(:hypotheses) do
      add :title, :string
      add :synopsis, :text

      timestamps
    end

  end
end
