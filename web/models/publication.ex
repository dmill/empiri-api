defmodule EmpiriApi.Publication do
  use EmpiriApi.Web, :model

  schema "publications" do
    field :title, :string
    field :abstract, :string
    field :published, :boolean, default: false
    field :deleted, :boolean, default: false

    timestamps
  end

  @required_fields ~w(title published deleted)
  @optional_fields ~w(abstract)

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


#