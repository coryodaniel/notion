defmodule NotionTest do
  use ExUnit.Case
  doctest Notion

  describe "moduledoc" do
    test "provides a moduledoc template" do
      Code.ensure_loaded(Foo)
      {:docs_v1, _, _, _, %{"en" => docs}, _, _} = Code.fetch_docs(Foo)

      assert String.contains?(docs, "`Foo` is a thin wrapper around")
      assert String.contains?(docs, "`[:foo, :qux]`")
    end

    test "interpolates variables if using a custom moduledoc" do
      Code.ensure_loaded(Bar)
      {:docs_v1, _, _, _, %{"en" => docs}, _, _} = Code.fetch_docs(Bar)

      assert String.contains?(docs, "Hi, I am bar")
      assert String.contains?(docs, "`[:bar, :dispatch, :succeeded]`")
      assert String.contains?(docs, ~s[%{env: "prod"}])
    end
  end

  test "name/0 returns the name of the instrumenter" do
    assert Bar.name() == :bar
  end

  test "metadata/0 returns the instrumenter's default metadata/metadata" do
    assert Bar.metadata() == %{env: "prod"}
  end

  describe "metadata/1" do
    test "metadata/1 merges a map with the instrumenter's default metadata/metadata" do
      assert Bar.metadata(%{region: "us-west"}) == %{env: "prod", region: "us-west"}
    end

    test "metadata/1 overrides values in the instrumenter's default metadata/metadata" do
      assert Bar.metadata(%{env: "staging"}) == %{env: "staging"}
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

    test "defines an arity 1 function" do
      assert Bar.greet(%{"latency" => 3}) == :ok
    end

    test "dispatches to telemetry", %{test: test_id} do
      log_handler = fn _name, _measurements, _metadata, _ ->
        assert true
      end

      :telemetry.attach(test_id, [:bar, :greet], log_handler, nil)

      Bar.greet(%{latency: 1})
    end
  end
end
