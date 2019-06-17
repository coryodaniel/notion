defmodule Foo do
  use Notion, name: :foo, metadata: %{region: "us-west"}
  @moduledoc false

  @doc "Send a qux"
  defevent(:qux)
end
