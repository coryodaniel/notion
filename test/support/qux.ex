defmodule Qux do
  use Notion, name: :qux, metadata: %{region: "us-west"}
  @moduledoc false

  @doc "Received an HTTP Request"
  @spec http_request(%{latency: integer}, %{}) :: :ok
  defevent([:http, :request])

  @spec users_signup(integer, %{}) :: :ok
  defevent([:users, :signup])
end
