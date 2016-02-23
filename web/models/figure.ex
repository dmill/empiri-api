defmodule EmpiriApi.Figure do
  use EmpiriApi.Web, :model
  use Arc.Ecto.Model

  schema "figures" do
    field :caption, :string
    field :position, :integer
    field :title, :string
    field :photo, EmpiriApi.FigurePhoto.Type

    belongs_to :section, EmpiriApi.Section

    timestamps
  end

  @required_fields ~w(title)
  @optional_fields ~w(caption position)

  @required_file_fields ~w()
  @optional_file_fields ~w(photo)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> cast_attachments(params, @required_file_fields, @optional_file_fields)
  end

  def photo_url(model) do
    url = EmpiriApi.FigurePhoto.url({model.photo, model}, :original)
    if url, do: "https://#{url}", else: nil
  end
end
