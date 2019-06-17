defmodule Notion do
  @moduledoc """
  Notion is a thin wrapper around [`:telemetry`](https://github.com/beam-telemetry/telemetry) that defines functions that dispatch telemetry events, documentation, and specs for your applications events.
  """

  @typedoc "An event name"
  @type event_name :: list(atom())

  @doc false
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @notion_name opts[:name]
      @notion_labels opts[:labels] || %{}

      Module.register_attribute(__MODULE__, :events, accumulate: true, persist: false)
      @before_compile Notion

      require Notion
      import Notion

      @spec name() :: atom
      @doc "The instrumenter name"
      def name(), do: @notion_name

      @spec labels() :: map
      @doc "Default labels/metadata"
      def labels(), do: @notion_labels

      @spec labels(map) :: map
      @doc "Merges labels with defaults"
      def labels(alt), do: Map.merge(labels(), alt)
    end
  end

  defmacro __before_compile__(env) do
    events = Module.get_attribute(env.module, :events)

    quote do
      @spec events() :: list(list(atom))
      @doc """
      List of all events emitted by this instrumenter. Great for use with `:telemetry.attach_many/4`
      """
      def events(), do: unquote(events)
    end
  end

  @typedoc """
  `defevent` macro option:

  * `measurements`: the typespec of your measurements, e.g. `map`
  * `metadata`: the typespec of your metadata, e.g. `map`

  For Dialyzer to pass, you [MUST] use atoms for your measurement and metadata keys.

  [MUST]: https://tools.ietf.org/html/rfc2119#section-1
  """
  @type defevent_option :: {:measurements, term()} | {:metadata, term()}

  defmodule EventOptions do
    @moduledoc false

    defstruct [:measurements, :metadata]

    def defaults(), do: [measurements: nil, metadata: nil]

    @spec from(list(Notion.defevent_option())) :: %__MODULE__{}
    def from(options) when is_list(options) do
      options = Keyword.merge(defaults(), options)
      struct!(__MODULE__, options)
    end
  end

  @doc """
  Define a function to send an event.

  ```elixir
  defevent [:event_suffix], measurements: map, metadata: map
  ```

  The `measurements` and `metadata` options [MUST] be a valid [typespec]. (`map` is fine.)

  If you'll never send `metadata`, leave it out, and Notion will define a 1-ary function.

  If you'll never send `measurements`, leave it out, and Notion will define a 0-ary function.

  [MUST]: https://tools.ietf.org/html/rfc2119#section-1
  [typespec]: https://hexdocs.pm/elixir/typespecs.html
  """
  @spec defevent(event_name(), list(EventOptions.options())) :: term()
  defmacro defevent(event, options \\ []) do
    event_options = EventOptions.from(options)

    names =
      case event do
        event when is_list(event) -> event
        event -> [event]
      end

    function_name = Enum.join(names, "_")

    case event_options do
      %EventOptions{measurements: nil, metadata: nil} ->
        quote do
          @event [@notion_name | unquote(names)]
          @events @event
          @spec unquote(:"#{function_name}")() :: :ok
          # credo:disable-for-next-line
          def unquote(:"#{function_name}")() do
            :telemetry.execute(@event, %{}, labels())
          end
        end

      %EventOptions{measurements: measurements, metadata: nil} ->
        quote do
          @event [@notion_name | unquote(names)]
          @events @event
          @spec unquote(:"#{function_name}")(unquote(measurements)) :: :ok
          # credo:disable-for-next-line
          def unquote(:"#{function_name}")(measurements) do
            :telemetry.execute(@event, measurements, labels())
          end
        end

      %EventOptions{measurements: measurements, metadata: metadata} ->
        quote do
          @event [@notion_name | unquote(names)]
          @events @event
          @spec unquote(:"#{function_name}")(unquote(measurements), unquote(metadata)) :: :ok
          # credo:disable-for-next-line
          def unquote(:"#{function_name}")(measurements, metadata) do
            labels = labels(metadata)
            :telemetry.execute(@event, measurements, labels)
          end
        end
    end
  end
end
