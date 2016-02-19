defmodule EmpiriApi.Section do
  use EmpiriApi.Web, :model

  schema "sections" do
    field :title, :string
    field :body, :string
    field :position, :integer
    belongs_to :publication, EmpiriApi.Publication

    timestamps
  end

  @required_fields ~w(title position)
  @optional_fields ~w(body)

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