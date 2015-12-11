defmodule EmpiriApi.RepoExtensionsTest do
  defmodule GetOrInsertBy do
    use EmpiriApi.ModelCase
    alias EmpiriApi.Repo
    alias EmpiriApi.User

    @function_name "get_or_insert_by/3"
    @user %User{email: "pugs@gmail.com", first_name: "Pug", last_name: "Jeremy",
                organization: "Harvard", title: "President",
                auth_id: "12345", auth_provider: "petco"}

    setup do
      Repo.insert(@user)
      :ok
    end

    def count_fun, do: Repo.all(from u in User, select: count(u.id)) |> List.first

    test "#{@function_name}: record exists based on clause, returns record" do
      {:ok, record} = Repo.get_or_insert_by(User, %{email: @user.email, last_name: @user.last_name})
      assert record.auth_id == @user.auth_id
    end

    test "#{@function_name}: record exists based on clause, does not insert" do
      record_count = count_fun
      Repo.get_or_insert_by(User, %{email: @user.email, last_name: @user.last_name})
      assert count_fun == record_count
    end

    test "#{@function_name}: record does not exist based on clause, attrs are invalid, does not insert new" do
      record_count = count_fun
      Repo.get_or_insert_by(User, %{email: "somethingelse@gmail.com", last_name: @user.last_name})
      assert count_fun == record_count
    end

    test "#{@function_name}: record does not exist based on clause, attrs are invalid, returns error" do
      {result, value} = Repo.get_or_insert_by(User, %{email: "somethingelse@gmail.com", last_name: @user.last_name})
      assert result == :error
    end

    test "#{@function_name}: record does not exist based on clause, attrs are valid, inserts new" do
      record_count = count_fun
      new_attrs = %{email: "thing@yahoo.com", first_name: "Turd", last_name: "Ferguson",auth_id: "7", auth_provider: "yahoo"}
      Repo.get_or_insert_by(User, %{email: new_attrs[:email]}, new_attrs)
      assert record_count + 1 == count_fun
    end

    test "#{@function_name}: record does not exist based on clause, attrs are valid, returns new" do
      new_attrs = %{email: "thing@yahoo.com", first_name: "Turd", last_name: "Ferguson",auth_id: "7", auth_provider: "yahoo"}
      {:ok, record} = Repo.get_or_insert_by(User, %{email: new_attrs[:email]}, new_attrs)
      assert record.email == new_attrs[:email]
    end
  end
end