defmodule EmpiriApi.Review do
  use EmpiriApi.Web, :model

  schema "reviews" do
    field :title, :string
    field :body, :string
    field :rating, :integer
    belongs_to :publication, EmpiriApi.Publication
    belongs_to :user, EmpiriApi.User

    timestamps
  end

  @required_fields ~w(title body rating user_id)
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
