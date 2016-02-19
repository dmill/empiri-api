defmodule EmpiriApi.Figure do
  use EmpiriApi.Web, :model

  schema "figures" do
    field :caption, :string
    field :position, :integer
    field :title, :string
    belongs_to :section, EmpiriApi.Section

    timestamps
  end

  @required_fields ~w(title)
  @optional_fields ~w(caption position)

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
