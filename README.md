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
    {:notion, "~> 0.1.1"}
  ]
end
```

## Usage

Add an `Instrumentation` module and `use Notion`.

Specify an app `:name` to be prepended to all events dispatched to telemetry. Optionally you can set `labels` that will be the defaults and merged with lower precendence for all events.

```elixir
defmodule MyApp.Instrumentation do
  use Notion, name: :my_app, labels: %{env: "prod"}

  @doc "Docs for my [:my_app, :cc_charge, :succeeded] event`
  defevent [:cc_charge, :succeeded]

  @doc "Docs for my [:my_app, :cc_charge, :failed] event`
  defevent [:cc_charge, :failed]
end
```

### Generated Event Functions

Notion will create three functions for each event, described below. In additiona any `@doc` provided before teh `defevent` call will be associated to that event. Typespecs are generated for all three function forms.

#### 0 arity event function form

When using the 0 arity `telemetry` will receive an empty map for `measurements` and the default `labels`.

```elixir
MyApp.Instrumentation.cc_charge_succeeded()
MyApp.Instrumentation.cc_charge_failed()
```

#### 1 arity event function form

When using the 1 arity `telemetry` will receive the provided `measurements` and the default `labels`.

```elixir
MyApp.Instrumentation.cc_charge_succeeded(%{"latency" => 300})
MyApp.Instrumentation.cc_charge_failed(%{"latency" => 300})
```

#### 2 arity event function form

When using the 2 arity `telemetry` will receive the provided `measurements` and will merge the provided `labels` with the defaults.

```elixir
MyApp.Instrumentation.cc_charge_succeeded(%{"latency" => 300}, %{"cc_type" => "visa"})
MyApp.Instrumentation.cc_charge_failed(%{"latency" => 300}, %{"cc_type" => "visa"})
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
