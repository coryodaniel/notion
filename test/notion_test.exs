defmodule NotionTest do
  use ExUnit.Case
  doctest Notion

  defmodule Bar do
    use Notion, name: :bar, labels: %{env: "prod"}

    @doc "When someone is greeted"
    defevent(:greet)

    @doc "When that thing is dispatched successfully"
    defevent([:dispatch, :succeeded])
  end

  test "name/0 returns the name of the instrumenter" do
    assert Bar.name() == :bar
  end

  test "labels/0 returns the instrumenter's default labels/metadata" do
    assert Bar.labels() == %{env: "prod"}
  end

  describe "labels/1" do
    test "labels/1 merges a map with the instrumenter's default labels/metadata" do
      assert Bar.labels(%{region: "us-west"}) == %{env: "prod", region: "us-west"}
    end

    test "labels/1 overrides values in the instrumenter's default labels/metadata" do
      assert Bar.labels(%{env: "staging"}) == %{env: "staging"}
    end
  end

  test "events/0 returns all registered events, prefixed with the instrumenter name" do
    events = Bar.events()
    assert Enum.member?(events, [:bar, :greet])
    assert Enum.member?(events, [:bar, :dispatch, :succeeded])
  end

  describe "defevent/1" do
    test "defines a function when given an atom" do
      assert Bar.greet(%{"latency" => 3}, %{"region" => "us-west"}) == :ok
    end

    test "defines a function given a list of atoms" do
      assert Bar.dispatch_succeeded(%{"time" => 5}, %{"region" => "us-east"}) == :ok
    end

    test "defines an arity 0 function" do
      assert Bar.greet() == :ok
    end

    test "defines an arity 1 function" do
      assert Bar.greet(%{"latency" => 3}) == :ok
    end
  end
end
