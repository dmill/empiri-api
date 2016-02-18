defmodule EmpiriApi.SectionController do
  use EmpiriApi.Web, :controller

  alias EmpiriApi.Publication
  alias EmpiriApi.Section

  plug AuthenticationPlug when action in [:create, :update, :delete]
  plug :translate_token_claims when action in [:create]
  plug :scrub_params, "section" when action in [:create, :update]

  def create(conn, %{"publication_id" => publication_id, "section" => section_params}) do
    publication = Repo.get!(Publication, publication_id)
    section = Ecto.build_assoc(publication, :sections) |> Section.changeset(section_params)

    case Repo.insert(section) do
      {:ok, section} ->
        conn
        |> put_status(:created)
        |> render("show.json", section: section)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmpiriApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def update(conn, %{"publication_id" => publication_id, "id" => id, "section" => section_params}) do
    section = Repo.get!(Section, id)
    changeset = Section.changeset(section, section_params)

    case Repo.update(changeset) do
      {:ok, section} ->
        render(conn, "show.json", section: section)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmpiriApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"publication_id" => publication_id, "id" => id}) do
    section = Repo.get!(Section, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(section)

    send_resp(conn, :no_content, "")
  end
end
