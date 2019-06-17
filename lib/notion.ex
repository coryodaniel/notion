defmodule Notion do
  @moduledoc """
  Notion is a thin wrapper around [`:telemetry`](https://github.com/beam-telemetry/telemetry) that defines functions that dispatch telemetry events, documentation, and specs for your applications events.
  """

  @moduledoc_template """
  `MODULE_NAME` is a thin wrapper around [`:telemetry`](https://github.com/beam-telemetry/telemetry).

  All events will be prefixed with `NOTION_NAME`.

  The following events are emitted:

  NOTION_EVENTS

  To access this list programmatically use `events/0`.

  If set, default metadata will be applied to all events. See: `metadata/0`
  """

  @doc false
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @notion_name opts[:name]
      @notion_metadata opts[:metadata] || %{}

      Module.register_attribute(__MODULE__, :events, accumulate: true, persist: false)
      @before_compile Notion

      require Notion
      import Notion

      @spec name() :: atom
      @doc "The instrumenter name"
      def name(), do: @notion_name

      @spec metadata() :: map
      @doc """
      Default metadata added to all events.

      Defaults:
      `#{inspect(@notion_metadata)}`
      """
      def metadata(), do: @notion_metadata

      @spec metadata(map) :: map
      @doc "Merges metadata with defaults"
      def metadata(alt), do: Map.merge(metadata(), alt)
    end
  end

  defmacro __before_compile__(env) do
    events = Module.get_attribute(env.module, :events)
    name = Module.get_attribute(env.module, :notion_name)
    metadata = Module.get_attribute(env.module, :notion_metadata)

    moduledoc =
      case Module.get_attribute(env.module, :moduledoc) do
        {_line, body} when is_binary(body) -> body
        _not_set -> @moduledoc_template
      end

    quote bind_quoted: [
            module_name: env.module,
            events: events,
            moduledoc: moduledoc,
            name: name,
            metadata: Macro.escape(metadata)
          ] do
      event_list = Enum.map(events, fn e -> "* `#{inspect(e)}` \n" end)
      module_name = String.replace("#{module_name}", ~r/Elixir\./, "")

      @moduledoc moduledoc
                 |> String.replace("MODULE_NAME", "#{module_name}")
                 |> String.replace("NOTION_NAME", "#{name}")
                 |> String.replace("NOTION_EVENTS", Enum.join(event_list, ""))
                 |> String.replace("NOTION_DEFAULT_METADATA", "`#{inspect(metadata)}`")

      @spec events() :: list(list(atom))
      @doc """
      Returns a list of all events emitted by this module:

      #{event_list}

      Great for use with `:telemetry.attach_many/4`
      """
      def events(), do: unquote(events)
    end
  end

  defmacro defevent(event) do
    names =
      case event do
        event when is_list(event) -> event
        event -> [event]
      end

    function_name = Enum.join(names, "_")

    quote do
      @event [@notion_name | unquote(names)]
      @events @event

      found_typespec =
        Enum.find(@spec, fn {:spec, {_, _lines, typespecs}, _} ->
          Enum.find(typespecs, fn ast ->
            case ast do
              {func_name, _, _} -> func_name == unquote(:"#{function_name}")
              _ -> false
            end
          end)
        end)

      if !found_typespec do
        @spec unquote(:"#{function_name}")(map, map) :: :ok
      end

      # credo:disable-for-next-line
      def unquote(:"#{function_name}")(measurements, metadata \\ %{}) do
        :telemetry.execute(@event, measurements, metadata(metadata))
        :ok
      end
    end
  end
end
