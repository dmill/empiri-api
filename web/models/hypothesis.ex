defmodule EmpiriApi.Hypothesis do
  use EmpiriApi.Web, :model
  alias EmpiriApi.Repo

  schema "hypotheses" do
    field     :title, :string
    field     :synopsis, :string
    field     :private, :boolean, default: true
    field     :deleted, :boolean, default: false
    has_many  :user_hypotheses, EmpiriApi.UserHypothesis
    has_many  :users, through: [:user_hypotheses, :user]

    timestamps
  end

  @required_fields ~w(title private deleted)
  @optional_fields ~w(synopsis)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> cast_assoc(:user_hypotheses, required: true)
  end

  def admins(model) do
    model = model |> Repo.preload([:users, :user_hypotheses])
    Enum.filter(model.users, fn(user) ->
                                model.user_hypotheses
                                |> Enum.find(fn(uh) -> uh.user_id == user.id && uh.admin end)
                             end)
  end
end
