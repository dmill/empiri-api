defmodule EmpiriApi.Repo.Migrations.AddPrivateColumnToHypotheses do
  use Ecto.Migration

  def change do
    alter table(:hypotheses) do
      add :private, :boolean, default: true
    end
  end
end
