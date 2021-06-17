defmodule TwinklyMaha.MixProject do
  use Mix.Project

  def project do
    [
      app: :twinkly_maha,
      version: "0.5.1-dev",
      elixir: "~> 1.11.2",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      docs: docs(),
      releases: [
        twinkly_maha: [
          include_executables_for: [:unix],
          steps: [:assemble, :tar]
        ]
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {TwinklyMaha.Application, []},
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
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ecto, ">= 3.4.4 and < 3.4.5"},
      {:ecto_sql, ">= 3.4.4 and < 3.4.5"},
      {:floki, ">= 0.0.0", only: :test},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.0"},
      {:phoenix, "~> 1.5.3"},
      {:phoenix_ecto, "~> 4.1"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_live_view, "~> 0.14.8"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_dashboard, "~> 0.3.6"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:sbom, git: "https://github.com/voltone/sbom"},
      {:tortoise, git: "https://github.com/gausby/tortoise.git", branch: "mqtt-5"},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "cmd npm install --prefix assets"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end

  defp docs do
    [
      extras: ["README.md"],
      main: "README",
      groups_for_modules: [
        Oc2: [~r/Oc2.*/],
        MQTT: [~r/Mqtt.*/]
        # TwinklyMaha
      ],
      nest_modules_by_prefix: [TwinklyMaha, TwinklyMahaWeb]
    ]
  end
end
