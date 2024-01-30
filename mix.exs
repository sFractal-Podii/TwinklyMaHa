defmodule TwinklyMaha.MixProject do
  use Mix.Project

  def project do
    [
      app: :twinkly_maha,
      version: "0.13.4",
      elixir: "~> 1.15.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers(),
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
      {:credo, "~> 1.7.0", only: [:dev, :test], runtime: false},
      {:ecto, ">= 3.7.1"},
      {:ecto_sql, "~> 3.9.0"},
      {:floki, ">= 0.0.0", only: :test},
      {:gettext, "~> 0.23.0"},
      {:jason, "~> 1.4.1"},
      {:plug_cowboy, "~> 2.6.1"},
      {:phoenix, "~> 1.6.6"},
      {:phoenix_ecto, "~> 4.4.2"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_live_view, "~> 0.16.4"},
      {:phoenix_html, "~> 3.3.1"},
      {:phoenix_live_reload, "~> 1.4.1", only: :dev},
      {:phoenix_live_dashboard, "~> 0.5"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 0.5.1"},
      {
        :sbom,
        only: :dev,
        git: "https://github.com/sigu/sbom.git",
        branch: "auto-install-bom",
        runtime: false
      },
      {
        :openc2,
        git: "https://github.com/sFractal-Podii/openc2.git", branch: "main"
      },
      {:emqtt, github: "emqx/emqtt", tag: "1.4.4", system_env: [{"BUILD_WITHOUT_QUIC", "1"}]},
      {:cowlib, "~> 2.11.0", override: true},
      {:ex_doc, "~> 0.31.0", only: :dev, runtime: false},
      {:esbuild, "~> 0.7.1", runtime: Mix.env() == :dev}
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
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.deploy": ["esbuild default --minify", "phx.digest"]
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
