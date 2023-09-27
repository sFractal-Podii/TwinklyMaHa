defmodule TwinklyMaha.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      TwinklyMaha.Repo,
      # Start the Telemetry supervisor
      TwinklyMahaWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: TwinklyMaha.PubSub},
      # Start the Endpoint (http/https)
      TwinklyMahaWeb.Endpoint,
      # start mqtt connection
      {Tortoise.Supervisor,
       [
         name: Oc2Mqtt.Connection.Supervisor,
         strategy: :one_for_one
       ]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TwinklyMaha.Supervisor]
    Supervisor.start_link(children, opts)
    # start connection
    Mqtt.start()
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TwinklyMahaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
