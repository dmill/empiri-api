defmodule EmpiriApi.ReferenceController do
  use EmpiriApi.Web, :controller

  alias EmpiriApi.Publication
  alias EmpiriApi.Reference

  plug AuthenticationPlug when action in [:create, :update, :delete]
  plug TranslateTokenClaimsPlug when action in [:create]
  plug :scrub_params, "reference" when action in [:create, :update]

  def create(conn, %{"publication_id" => publication_id, "reference" => reference_params}) do
    publication = Repo.get!(Publication, publication_id)
    changeset = Ecto.build_assoc(publication, :references) |> Reference.changeset(reference_params)

    case Repo.insert(changeset) do
      {:ok, reference} ->
        conn
        |> put_status(:created)
        |> render("show.json", reference: reference)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmpiriApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "reference" => reference_params}) do
    reference = Repo.get!(Reference, id)
    changeset = Reference.changeset(reference, reference_params)

    case Repo.update(changeset) do
      {:ok, reference} ->
        render(conn, "show.json", reference: reference)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmpiriApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    reference = Repo.get!(Reference, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(reference)

    send_resp(conn, :no_content, "")
  end
end
