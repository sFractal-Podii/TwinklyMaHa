defmodule Mqtt do
  @moduledoc """
  `Mqtt` is main module for handling mqtt
  mqtt.start initializes the system
     and starts the Tortoise mqtt client using mqtt.handler
  """

  require Logger

  @doc """
  Start initializes system variables
  and starts supervisor of mqtt client
  """
  def start do
    client_id =
      System.get_env("CLIENT_ID") ||
        raise """
        environment variable CLIENT_ID is missing.
        For example:
        export CLIENT_ID=:sfractal2020
        """

    Logger.info("client_id is #{client_id}")

    mqtt_host =
      System.get_env("MQTT_HOST") ||
        raise """
        environment variable HOST is missing.
        Examples:
        export MQTT_HOST="35.221.11.97 "
        export MQTT_HOST="mqtt.sfractal.com"
        """

    Logger.info("mqtt_host is #{mqtt_host}")

    mqtt_port =
      String.to_integer(
        System.get_env("MQTT_PORT") ||
          raise("""
          environment variable MQTT_PORT is missing.
          Example:
          export MQTT_PORT=1883
          """)
      )

    Logger.info("mqtt_port is #{mqtt_port}")

    server = {Tortoise.Transport.Tcp, host: mqtt_host, port: mqtt_port}

    user_name =
      System.get_env("USER_NAME") ||
        raise """
        environment variable USER_NAME is missing.
        Examples:
        export USER_NAME="plug"
        """

    Logger.info("user_name is #{user_name}")

    _password =
      System.get_env("PASSWORD") ||
        raise """
        environment variable PASSWORD is missing.
        Example:
        export PASSWORD="fest"
        """

    Logger.info("password set")

    # {:ok, _} =
    #   Tortoise.Supervisor.start_child(
    #     Oc2Mqtt.Connection.Supervisor,
    #     client_id: client_id,
    #     handler: {Mqtt.Handler, [name: client_id]},
    #     server: server,
    #     # user_name: user_name,
    #     # password: password,
    #     subscriptions: [{"oc2/cmd/device/t01", 0}]
    #   )
    opts = [
      host: mqtt_host,
      port: mqtt_port,
      protocol_version: :"5",
      ssl: true,
      client_id: client_id,
      # username: user_name,
      # password: password,
      clean_start: false,
      ssl_opts: [
        cacerts: :certifi.cacerts(),
        keyfile: ~c"/etc/mqtt/certs/client.key",
        certfile: ~c"/etc/mqtt/certs/client.crt"
      ],
      start_when: {{Oc2Mqtt.Connection.Supervisor, :connected?, []}, 2000},
      message_handler: {Mqtt.Handler, []},
      subscriptions: [
        {"foo/#", 1},
        {"baz/+", 0}
      ]
    ]

    ExMQTT.Supervisor.start_link(opts) |> IO.inspect(label: "start+++++++++++++++")
  end
end
