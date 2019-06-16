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

      @spec unquote(:"#{function_name}")(map) :: :ok
      # credo:disable-for-next-line
      def unquote(:"#{function_name}")(measurements \\ %{}) do
        :telemetry.execute(@event, measurements, labels())
      end

      @spec unquote(:"#{function_name}")(map, map) :: :ok
      # credo:disable-for-next-line
      def unquote(:"#{function_name}")(measurements, metadata) do
        labels = labels(metadata)
        :telemetry.execute(@event, measurements, labels)
      end
    end
  end
end
