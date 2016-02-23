defmodule EmpiriApi.User do
  use EmpiriApi.Web, :model
  use Arc.Ecto.Model

  schema "users" do
    field     :first_name, :string
    field     :last_name, :string
    field     :title, :string
    field     :email, :string
    field     :organization, :string
    field     :auth_id, :string
    field     :auth_provider, :string
    field     :external_photo_url, :string
    field     :profile_photo, EmpiriApi.ProfilePhoto.Type

    has_many  :user_hypotheses, EmpiriApi.UserHypothesis
    has_many  :hypotheses, through: [:user_hypotheses, :hypothesis]

    has_many :user_publications, EmpiriApi.UserPublication
    has_many :publications, through: [:user_publications, :publication]

    has_many :reviews, EmpiriApi.Review

    timestamps
  end

  @required_fields ~w(email auth_id auth_provider)
  @optional_fields ~w(first_name last_name title organization external_photo_url)

  @required_file_fields ~w()
  @optional_file_fields ~w(profile_photo)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> cast_assoc(:user_hypotheses)
    |> cast_attachments(params, @required_file_fields, @optional_file_fields)
    |> validate_format(:email, ~r/@/)
    |> update_change(:email, &String.downcase/1)
    |> update_change(:first_name, &String.capitalize/1)
    |> update_change(:last_name, &String.capitalize/1)
    |> update_change(:title, &String.capitalize/1)
    |> unique_constraint(:auth_id, name: :users_auth_id_auth_provider_index)
  end

  def photo_url(model) do
    url = EmpiriApi.ProfilePhoto.url({model.profile_photo, model}, :original)
    if url, do: "https://#{url}", else: nil
  end
end
