defmodule Notion.MixProject do
  use Mix.Project

  def project do
    [
      app: :notion,
      description: description(),
      version: "0.1.2",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env()),
      dialyzer: [plt_add_apps: [:mix, :eex]],
      docs: [
        extras: ["README.md"],
        main: "readme"
      ]
    ]
  end

  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:telemetry, "~> 0.4.0"},
      # {:prometheus_ex, "~> 3.0"},

      # Dev deps
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.20", only: :dev},
      {:mix_test_watch, "~> 0.8", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      name: :notion,
      maintainers: ["Cory O'Daniel"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/coryodaniel/notion"
      }
    ]
  end

  defp description do
    "Notion is a thin wrapper around telemetry that defines functions that dispatch telemetry events, documentation, and specs for your applications events."
  end
end
