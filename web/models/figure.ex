defmodule EmpiriApi.Figure do
  use EmpiriApi.Web, :model
  use Arc.Ecto.Model
  alias EmpiriApi.Repo

  schema "figures" do
    field :caption, :string
    field :position, :integer
    field :title, :string
    field :photo, EmpiriApi.FigurePhoto.Type

    belongs_to :section, EmpiriApi.Section

    timestamps
  end

  @required_fields ~w(position)
  @optional_fields ~w(title caption)

  @required_file_fields ~w()
  @optional_file_fields ~w(photo)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    params = increment_position(model, atomize_params(params))

    model
    |> cast(params, @required_fields, @optional_fields)
    |> cast_attachments(params, @required_file_fields, @optional_file_fields)
  end

  def photo_url(model) do
    url = EmpiriApi.FigurePhoto.url({model.photo, model}, :original)
    if url, do: "https://#{url}", else: nil
  end

  def thumbnail_photo_url(model) do
    url = EmpiriApi.FigurePhoto.url({model.photo, model}, :thumb)
    if url, do: "https://#{url}", else: nil
  end

  def siblings(model) do
    model = model |> Repo.preload([:section])
    (model.section |> Repo.preload([:figures])).figures
  end

  def increment_position(model, params) do
    if !model.position && !params[:position] do
      figures = siblings(model)
      last_position = Enum.reduce(figures, -1, fn(fig, acc) ->
                                                if fig.position && fig.position > acc do
                                                  fig.position
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
