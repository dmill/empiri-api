defmodule EmpiriApi.HypothesisTest do
  use EmpiriApi.ModelCase

  alias EmpiriApi.Hypothesis

  @valid_attrs %{synopsis: "some content", title: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Hypothesis.changeset(%Hypothesis{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Hypothesis.changeset(%Hypothesis{}, @invalid_attrs)
    refute changeset.valid?
  end
end
