defmodule EmpiriApi.HypothesisController do
  use EmpiriApi.Web, :controller

  alias EmpiriApi.Hypothesis

  plug :scrub_params, "hypothesis" when action in [:create, :update]

  # def index(conn, _params) do
    # hypotheses = Repo.all(Hypothesis)
    # render(conn, "index.json", hypotheses: hypotheses)
  # end

  def create(conn, %{"hypothesis" => hypothesis_params}) do
    changeset = Hypothesis.changeset(%Hypothesis{}, hypothesis_params)

    case Repo.insert(changeset) do
      {:ok, hypothesis} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", hypothesis_path(conn, :show, hypothesis))
        |> render("show.json", hypothesis: hypothesis)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmpiriApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    hypothesis = Repo.get!(Hypothesis, id)
    render(conn, "show.json", hypothesis: hypothesis)
  end

  def update(conn, %{"id" => id, "hypothesis" => hypothesis_params}) do
    hypothesis = Repo.get!(Hypothesis, id)
    changeset = Hypothesis.changeset(hypothesis, hypothesis_params)

    case Repo.update(changeset) do
      {:ok, hypothesis} ->
        render(conn, "show.json", hypothesis: hypothesis)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(EmpiriApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    hypothesis = Repo.get!(Hypothesis, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(hypothesis)

    send_resp(conn, :no_content, "")
  end
end
