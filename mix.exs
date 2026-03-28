defmodule TwinklyMaha.MixProject do
  use Mix.Project

  def project do
    [
      app: :twinkly_maha,
      version: "0.14.0-dev",
      elixir: "~> 1.17.0",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
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
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:floki, ">= 0.0.0", only: :test},
      {:gettext, "~> 1.0"},
      {:jason, "~> 1.4"},
      {:plug_cowboy, "~> 2.7"},
      {:phoenix, "~> 1.7"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_live_view, "~> 1.0"},
      {:phoenix_html, "~> 4.3.0"},
      {:phoenix_live_reload, "~> 1.6.0", only: :dev},
      {:phoenix_live_dashboard, "~> 0.8"},
      {:telemetry_metrics, "~> 1.1.0"},
      {:telemetry_poller, "~> 1.3.0"},
      {:sbom,
       only: :dev,
       git: "https://github.com/sigu/sbom.git",
       branch: "auto-install-bom",
       runtime: false},
      {
        :openc2,
        git: "https://github.com/sFractal-Podii/openc2.git", branch: "main"
      },
      {:emqtt, github: "emqx/emqtt", tag: "1.14.7", system_env: [{"BUILD_WITHOUT_QUIC", "1"}]},
      {:esbuild, "~> 0.10.0", runtime: Mix.env() == :dev},
      {:cowlib, "~> 2.16.0", override: true},
      {:ex_doc, "~> 0.39.1", only: :dev, runtime: false},
      {:phoenix_html_helpers, "~> 1.0"},
      {:phoenix_view, "~> 2.0"},
      {:lazy_html, ">= 0.1.0", only: :test}
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
      setup: ["deps.get", "cmd npm install --prefix assets"],
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
