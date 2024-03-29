defmodule EmpiriApi.Publication do
  use EmpiriApi.Web, :model
  alias EmpiriApi.Repo

  schema "publications" do
    field :title, :string
    field :abstract, :string
    field :published, :boolean, default: false
    field :deleted, :boolean, default: false
    field :first_author_id, :integer
    field :last_author_id, :integer

    has_many  :user_publications, EmpiriApi.UserPublication
    has_many  :users, through: [:user_publications, :user]
    has_many  :authors, EmpiriApi.Author
    has_many  :sections, EmpiriApi.Section
    has_many  :references, EmpiriApi.Reference
    has_many  :reviews, EmpiriApi.Review

    timestamps
  end

  @required_fields ~w(title published deleted)
  @optional_fields ~w(abstract first_author_id last_author_id)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> cast_assoc(:user_publications, required: true)
    |> cast_assoc(:authors)
  end

  def admins(model) do
    model = model |> Repo.preload([:users, :user_publications])
    Enum.filter(model.users, fn(user) ->
                                model.user_publications
                                |> Enum.find(fn(uh) -> uh.user_id == user.id && uh.admin end)
                             end)
  end

  def sentiment(model) do
    if review_count(model) > 0, do: positive_review_count(model) / review_count(model)
  end

  def review_count(model), do: (model |> Repo.preload([:reviews])).reviews |> Enum.count

  def positive_review_count(model), do: review_type_count(model, 1)

  def negative_review_count(model), do: review_type_count(model, -1)

  def needs_revision_review_count(model), do: review_type_count(model, 0)

  defp review_type_count(model, type) do
    (model |> Repo.preload([:reviews])).reviews
      |> Enum.reduce(0, fn(rev, acc) ->
            if rev.rating == type, do: acc + 1, else: acc
         end)
  end
end
