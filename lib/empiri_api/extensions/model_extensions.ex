defmodule EmpiriApi.Extensions.ModelExtensions do
  alias EmpiriApi.Repo

  def atomize_params(params) do
    Enum.reduce(params, %{},  fn({k,v}, acc) ->
                                if !is_atom(k) do
                                  Map.put(acc, String.to_atom(k), v)
                                else
                                  Map.put(acc, k, v)
                                end
                              end)
  end
end
