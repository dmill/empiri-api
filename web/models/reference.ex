defmodule EmpiriApi.Reference do
  use EmpiriApi.Web, :model

  schema "references" do
    field :authors, :string
    field :title, :string
    field :link, :string
    belongs_to :publication, EmpiriApi.Publication

    timestamps
  end

  @required_fields ~w(authors title link)
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
