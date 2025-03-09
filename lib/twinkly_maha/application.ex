defmodule TwinklyMaha.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      TwinklyMahaWeb.Telemetry,
      {Phoenix.PubSub, name: TwinklyMaha.PubSub},
      TwinklyMahaWeb.Endpoint,
      Emqtt.Emqx,
      Emqtt.Hivemq
    ]

    opts = [strategy: :one_for_one, name: TwinklyMaha.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TwinklyMahaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
