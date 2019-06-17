# Notion

[![Build Status](https://travis-ci.org/coryodaniel/notion.svg?branch=master)](https://travis-ci.org/coryodaniel/notion)
[![Hex.pm](http://img.shields.io/hexpm/v/notion.svg?style=flat)](https://hex.pm/packages/notion)
![Hex.pm](https://img.shields.io/hexpm/l/notion.svg?style=flat)

Notion is a thin wrapper around [`:telemetry`](https://github.com/beam-telemetry/telemetry) that defines functions that dispatch telemetry events, documentation, and specs for your applications events.

## Installation

The package can be installed by adding `notion` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:notion, "~> 0.2.0"}
  ]
end
```

## Usage

Add an `Instrumentation` module and `use Notion`.

Specify an app `:name` to be prepended to all events dispatched to telemetry. Optionally you can set `metadata` that will be the defaults and merged with lower precendence for all events.

```elixir
defmodule MyApp.Instrumentation do
  use Notion, name: :my_app, metadata: %{env: "prod"}

  @doc "Processed an HTTP request"
  # Generate a default typespec of http_request(map, map) :: :ok
  defevent [:http, :request]

  @doc "Docs for my [:my_app, :cc_charge, :succeeded] event"
  # Override a typespec
  @spec cc_charge_succeeded(integer, map) :: :ok
  defevent [:cc_charge, :succeeded]

  @doc "Docs for my [:my_app, :cc_charge, :failed] event"
  defevent [:cc_charge, :failed]
end
```

### Generated `@moduledoc`

A default `@moduledoc` will be generated for your module. To override it, simple re-define `@moduledoc`. Four "variables" exist that can be interpolated into your docs:

- `MODULE_NAME` - The name of the module using Notion
- `NOTION_NAME` - will be the value `name` in `use Notion, name: :foo`
- `NOTION_EVENTS` - a markdown formatted unordered list of emitted events
- `NOTION_DEFAULT_METADATA` the default metadata added to events, if set.

### Generated Event Functions

Notion will create two functions for each event, described below. In additiona any `@doc` provided before the `defevent` call will be associated to that event.

The following default typespec will be added for each function.

```elixir
@spec function_name(map(), map()) :: ok
```

#### 1 arity event function form

When using the 1 arity `telemetry` will receive the provided `measurements` and the default `metadata`.

```elixir
MyApp.Instrumentation.cc_charge_succeeded(%{"latency" => 300})
MyApp.Instrumentation.cc_charge_failed(%{"latency" => 300})
```

#### 2 arity event function form

When using the 2 arity `telemetry` will receive the provided `measurements` and will merge the provided `metadata` with the defaults.

```elixir
MyApp.Instrumentation.cc_charge_succeeded(%{"latency" => 300}, %{"cc_type" => "visa"})
MyApp.Instrumentation.cc_charge_failed(%{"latency" => 300}, %{"cc_type" => "visa"})
```

### Overriding the default typespec for an event

To override the default typespec of `map(), map()` simple define a `@spec` before calling `defevent/0`. Note, the return type will always be `:ok`.

```elixir
defmodule MyApp.Telemetry do
  @spec foo(integer, %{my_label: binary}) :: :ok
  defevent :foo
end
```

### Attaching all events to a handler

Notion provides a `events/0` function that provides all the event names telemetry receives. This is handy for binding handlers to

```elixir
def MyApp.InstrumentationHandler do
  def setup() do
    :telemetry.attach_many("my-app-handler", MyApp.Instrumentation.events(), &handle_event/4, nil)
  end

  def handle_event(event, measurements, _metadata, _config) do
    IO.puts("Dispatched: #{inspect(event)} -> #{inspect(measurements)}")
  end
end
```

Documentation can be be found at [https://hexdocs.pm/notion](https://hexdocs.pm/notion).
