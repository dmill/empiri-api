defmodule EmpiriApi.Repo.Migrations.ChangeHypothesisTitleToTextField do
  use Ecto.Migration

  def change do
    alter table(:hypotheses) do
      modify :title, :text
    end
  end
end
