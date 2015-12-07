defmodule EmpiriApi.Helpers do
  defmodule RepoExtensions do

    alias EmpiriApi.Repo

    @doc """
    Looks for a record in the repo for a given model. If a record is found it will return:

    {:ok, model}

    If no record is found, it will generate a changeset for the model and attempt to insert
    with the given attrs. If the changeset is valid, it will return:

    {:ok, model}

    If the changeset is invalid, it will return:

    {:ok, model}
    """
    @spec get_or_insert_by(Ecto.Model.t, Map.t, Map.t) ::
      {:ok, Ecto.Model.t} | {:error, Ecto.Changeset.t}
    def get_or_insert_by(model, clauses, attrs \\ %{}) do
      record = Repo.get_by(model, clauses)

      if record do
        {:ok, record}
      else
        Repo.insert(model.changeset(struct(model), attrs))
      end
    end
  end
end