defmodule EmpiriApi.Hypothesis do
  use EmpiriApi.Web, :model

  schema "hypotheses" do
    field     :title, :string
    field     :synopsis, :string
    field     :private, :boolean, default: true
    has_many  :user_hypotheses, EmpiriApi.UserHypothesis
    has_many  :users, through: [:user_hypotheses, :user]

    timestamps
  end

  @required_fields ~w(title private)
  @optional_fields ~w(synopsis)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> cast_assoc(:user_hypotheses)
  end
end
