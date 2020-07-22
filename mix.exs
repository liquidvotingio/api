defmodule LiquidVoting.MixProject do
  use Mix.Project

  def project do
    [
      app: :liquid_voting,
      version: "0.1.0",
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {LiquidVoting.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.10"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.1"},
      {:postgrex, "~> 0.15.0"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:corsica, "~> 1.0"},
      {:absinthe, "~> 1.5.0-beta.2"},
      {:absinthe_plug, "~> 1.5.0-alpha.0"},
      {:absinthe_phoenix, "~> 1.5.0-alpha.0"},
      {:dataloader, "~> 1.0.6"},
      {:credo, "~> 1.4.0", only: [:dev, :test], runtime: false},
      {:telemetry, "~> 0.4.0"},
      {:prometheus_ex, "~> 3.0.5"},
      {:prometheus_ecto, "~> 1.4.3"},
      {:prometheus_phoenix, "~> 1.3.0"},
      {:prometheus_plugs, "~> 1.1.5"},
      {:ex_machina, "~> 2.3", only: :test},
      {:ecto_fields, "~> 1.2.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.migrate", "test"]
    ]
  end
end
