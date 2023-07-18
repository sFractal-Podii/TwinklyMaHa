defmodule Mqtt.Handler do
  @moduledoc """
  Mqtt.Handler is a behaviour of Tortoise for handling mqtt
  It allows for connections, subscriptons, and handles messages.
  The mqtt-specific code is here; and this module calls oc2 for
  OpenC2 parsing and execution
  """

  require Logger

  defstruct [:name]
  alias __MODULE__, as: State

  @behaviour Tortoise.Handler

  @impl true
  def init(opts) do
    name = Keyword.get(opts, :name)
    {:ok, %State{name: name}}
  end

  @impl true
  def connection(:up, state) do
    Logger.info("MQTT Connection has been established")
    {:ok, state}
  end

  def connection(:down, state) do
    Logger.warn("Connection has been dropped")
    {:ok, state}
  end

  @impl true
  def subscription(:up, topic, state) do
    Logger.info("Subscribed to #{topic}")
    {:ok, state}
  end

  def subscription({:warn, [requested: req, accepted: qos]}, topic, state) do
    Logger.warn("Subscribed to #{topic}; requested #{req} but got accepted with QoS #{qos}")
    {:ok, state}
  end

  def subscription({:error, reason}, topic, state) do
    Logger.error("Error subscribing to #{topic}; #{inspect(reason)}")
    {:ok, state}
  end

  def subscription(:down, topic, state) do
    Logger.info("Unsubscribed from #{topic}")
    {:ok, state}
  end

  @impl true
  def handle_message(["oc2", "cmd", "device", "t01"], msg, state) do
    Logger.info("id: #{state.name}")
    Logger.info("topic: oc2/cmd/device/t01")
    Logger.info("msg: #{inspect(msg)}")

    res =
      msg
      |> Openc2.Oc2.Command.new()
      # execute
      |> Openc2.Oc2.Command.do_cmd()
      |> Mqtt.Command.return_result()

    case res do
      {:ok, command} ->
        Phoenix.PubSub.broadcast(TwinklyMaha.PubSub, "leds", command.target_specifier)
        Logger.info("handle_msg: status :ok")
        Logger.info("handle_msg: command #{inspect(command)}")
        Logger.info("state: #{inspect(state)}")

      {:error, msg} ->
        Logger.error("handle_msg: status :error")
        Logger.error("handle_msg: #{inspect(msg)}")
        Logger.error("state: #{inspect(state)}")
    end

    # check if we can publish from here

    {:ok, state}
  end

  def handle_message(topic, msg, state) do
    Logger.info("topic != oc2/cmd/device/t01")
    Logger.info("#{state.name}, #{Enum.join(topic, "/")} #{inspect(msg)}")
    {:ok, state}
  end

  @impl true
  def terminate(reason, _state) do
    Logger.warn("Client has been terminated with reason: #{inspect(reason)}")
    :ok
  end
end
