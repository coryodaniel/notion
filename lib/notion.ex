defmodule Notion do
  @moduledoc """
  Notion is a thin wrapper around [`:telemetry`](https://github.com/beam-telemetry/telemetry) that defines functions that dispatch telemetry events, documentation, and specs for your applications events.
  """

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

  defmodule EventOptions do
    @moduledoc "Event Options"

    defstruct [:t_measurements, :t_metadata, :defaults]

    @doc false
    def defaults() do
      [
        t_measurements: {:map, [], Elixir},
        t_metadata: {:map, [], Elixir},
        defaults: :measurements_and_metadata
      ]
    end

    @typedoc """
    Specifies which arguments get defaults:

    * `:measurements_and_metadata`: both arguments
    * `:metadata_only`: only the last argument
    * `:nil`: neither argument
    """
    @type defaults_value :: :measurements_and_metadata | :metadata_only | nil

    @typedoc """
    `defevent` macro options:

    * `t_measurements`: the typespec of your measurements (default: `map`)
    * `t_metadata`: the typespec of your metadata (default: `map`)
    * `defaults`: which arguments get default arguments

    For Dialyzer to not complain, you [MUST]:

    * Use atoms for your measurement and metadata keys

    * Set `defaults` to `:metadata_only` if you have any `required` keys in your measurements,
      and to `:nil` if you have any `required` keys in your `metadata`.

    [MUST]: https://tools.ietf.org/html/rfc2119#section-1
    """
    @type option ::
            {:t_measurements, term()}
            | {:t_metadata, term()}
            | {:defaults, defaults_value()}

    @doc false
    def from(options) when is_list(options) do
      options = Keyword.merge(defaults(), options)
      IO.inspect(options)
      struct!(__MODULE__, options)
    end
  end

  @spec defevent(list(atom), list(EventOptions.options())) :: term()
  defmacro defevent(event, options \\ []) do
    event_options = EventOptions.from(options)

    names =
      case event do
        event when is_list(event) -> event
        event -> [event]
      end

    function_name = Enum.join(names, "_")

    case event_options.defaults do
      :measurements_and_metadata ->
        quote do
          @event [@notion_name | unquote(names)]
          @events @event
          @spec unquote(:"#{function_name}")(
                  unquote(event_options.t_measurements),
                  unquote(event_options.t_metadata)
                ) :: :ok
          # credo:disable-for-next-line
          def unquote(:"#{function_name}")(measurements \\ %{}, metadata \\ %{}) do
            labels = labels(metadata)
            :telemetry.execute(@event, measurements, labels)
          end
        end

      :metadata_only ->
        quote do
          @event [@notion_name | unquote(names)]
          @events @event
          @spec unquote(:"#{function_name}")(
                  unquote(event_options.t_measurements),
                  unquote(event_options.t_metadata)
                ) :: :ok
          # credo:disable-for-next-line
          def unquote(:"#{function_name}")(measurements, metadata \\ %{}) do
            labels = labels(metadata)
            :telemetry.execute(@event, measurements, labels)
          end
        end

      nil ->
        quote do
          @event [@notion_name | unquote(names)]
          @events @event
          @spec unquote(:"#{function_name}")(
                  unquote(event_options.t_measurements),
                  unquote(event_options.t_metadata)
                ) :: :ok
          # credo:disable-for-next-line
          def unquote(:"#{function_name}")(measurements, metadata) do
            labels = labels(metadata)
            :telemetry.execute(@event, measurements, labels)
          end
        end
    end
  end
end
