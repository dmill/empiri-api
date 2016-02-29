defmodule EmpiriApi.FigureController do
  use EmpiriApi.Web, :controller

  alias EmpiriApi.Figure
  alias EmpiriApi.Section
  alias EmpiriApi.Publication
  alias EmpiriApi.UserPublication

  plug AuthenticationPlug when action in [:create, :update, :delete]
  plug TranslateTokenClaimsPlug when action in [:create, :update, :delete]
  plug CurrentUserPlug when action in [:create, :update, :delete]
  plug AuthorizationPlug, %{resource_type: Publication,
                            ownership_on_associated: UserPublication,
                            admin: true,
                            param: "publication_id"} when action in [:update, :delete]

  plug :scrub_params, "figure" when action in [:create, :update]

  def create(conn, %{"publication_id" => _publication_id, "section_id" => section_id,"figure" => figure_params}) do
    section = Repo.get!(Section, section_id)
    changeset = Ecto.build_assoc(section, :figures) |> Figure.changeset(figure_params)

    case Repo.insert(changeset) do
      {:ok, figure} ->
        conn
        |> put_status(:created)
        |> render("show.json", figure: figure)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmpiriApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def update(conn, %{"publication_id" => _publication_id, "section_id" => section_id, "id" => id, "figure" => figure_params}) do
    figure = Repo.get!(Figure, id)
    changeset = Figure.changeset(figure, figure_params)

    case Repo.update(changeset) do
      {:ok, figure} ->
        render(conn, "show.json", figure: figure)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmpiriApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    figure = Repo.get!(Figure, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(figure)

    send_resp(conn, :no_content, "")
  end
end
