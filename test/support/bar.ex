defmodule Bar do
  use Notion, name: :bar, metadata: %{env: "prod"}

  @moduledoc """
  Hi, I am NOTION_NAME.

  I produce:

  NOTION_EVENTS

  My default metadata is:

  NOTION_DEFAULT_METADATA
  """

  @doc "When someone is greeted"
  defevent(:greet)

  @doc "When that thing is dispatched successfully"
  defevent([:dispatch, :succeeded])
end
