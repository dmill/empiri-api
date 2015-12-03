defmodule EmpiriApi.User do
  use EmpiriApi.Web, :model

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :title, :string
    field :email, :string
    field :organization, :string
    field :auth_id, :string
    field :auth_provider, :string
    field :photo_url, :string

    timestamps
  end

  @required_fields ~w(first_name last_name email auth_id auth_provider)
  @optional_fields ~w(title organization photo_url)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_format(:email, ~r/@/)
  end
end
