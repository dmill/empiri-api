defmodule EmpiriApi.Section do
  use EmpiriApi.Web, :model
  alias EmpiriApi.Repo

  schema "sections" do
    field :title, :string
    field :body, :string
    field :position, :integer
    belongs_to :publication, EmpiriApi.Publication
    has_many :figures, EmpiriApi.Figure

    timestamps
  end

  @required_fields ~w(position)
  @optional_fields ~w(title body)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    params = increment_position(model, atomize_params(params))

    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def siblings(model) do
    model = model |> Repo.preload([:publication])
    (model.publication |> Repo.preload([:sections])).sections
  end

  def increment_position(model, params) do
    if !model.position && !params[:position] do
      sections = siblings(model)
      last_position = Enum.reduce(sections, -1, fn(sec, acc) ->
                                                  if sec.position && sec.position > acc do
                                                    sec.position
                                                  else
                                                    acc
                                                  end
                                                end)
      Map.put(params, :position, last_position + 1)
    else
      params
    end
  end
end
