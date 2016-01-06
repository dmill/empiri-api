defmodule EmpiriApi.Repo.Migrations.AddReferencesToUserHypotheses do
  use Ecto.Migration

  def change do
    alter table(:user_hypotheses) do
      modify :user_id, references(:users)
      modify :hypothesis_id, references(:hypotheses)
    end
  end
end
