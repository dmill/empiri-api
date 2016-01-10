defmodule EmpiriApi.Repo.Migrations.AddDeletedToHypotheses do
  use Ecto.Migration

  def change do
      alter table(:hypotheses) do
        add :deleted, :boolean, default: true
    end
  end
end
