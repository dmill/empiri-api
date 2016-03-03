defmodule EmpiriApi.FigurePhotosController do
  use EmpiriApi.Web, :controller
  alias EmpiriApi.Figure
  alias EmpiriApi.Section
  alias EmpiriApi.Publication
  alias EmpiriApi.UserPublication

  plug AuthenticationPlug when action in [:create, :update]
  plug TranslateTokenClaimsPlug when action in [:create, :update]
  plug CurrentUserPlug when action in [:create, :update]
  plug AuthorizationPlug, %{resource_type: Publication,
                            ownership_on_associated: UserPublication,
                            admin: true,
                            param: "publication_id"} when action in [:create, :update]
  plug :scrub_params, "photo" when action in [:create, :update]


  def create(conn, %{"section_id" => section_id, "photo" => photo}) do
    section = Repo.get!(Section, section_id)
    figure = Ecto.build_assoc(section, :figures, %{}) |> Figure.changeset(%{}) |> Repo.insert!
    changeset = Figure.changeset(figure, %{photo: photo})

    update_figure(conn, changeset, figure)
  end

  #Need to delete old objects if they are being updated!
  def update(conn, %{"figure_id" => figure_id, "photo" => photo}) do
    figure = Repo.get!(Figure, figure_id)
    changeset = Figure.changeset(figure, %{photo: photo})

    update_figure(conn, changeset, figure)
  end

  defp update_figure(conn, changeset, figure) do
    case Repo.update(changeset) do
      {:ok, figure} ->
        conn
        |> render(EmpiriApi.FigureView, "show.json", figure: figure)
      {:error, changeset} ->
        Repo.delete!(figure)

        conn
        |> put_status(:unprocessable_entity)
        |> render(EmpiriApi.ChangesetView, "error.json", changeset: changeset)
    end
  end
end
