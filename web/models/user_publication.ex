defmodule EmpiriApi.UserPublication do
  use EmpiriApi.Web, :model

  schema "user_publications" do
    field :admin, :boolean, default: false
    belongs_to :user, EmpiriApi.User
    belongs_to :publication, EmpiriApi.Publication

    timestamps
  end

  @required_fields ~w(admin)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
