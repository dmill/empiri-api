defmodule EmpiriApi.Repo.Migrations.CreateUserHypothesesTable do
  use Ecto.Migration

  def change do
    create table(:user_hypotheses) do
      add :user_id, :integer
      add :hypothesis_id, :integer
      add :admin, :boolean

      timestamps
    end
  end
end
