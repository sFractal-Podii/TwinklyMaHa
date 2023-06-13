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
  def handle_message(["oc2", "cmd", "device", "sf_tw_01"], msg, state) do
    Logger.info("id: #{state.name}")
    Logger.info("topic: oc2/cmd/device/sf_tw_01")
    Logger.info("msg: #{inspect(msg)}")

    {status, result} =
      msg
      # initialize struct
      |> Oc2.Command.new()
      # execute
      |> Oc2.Command.do_cmd()
      # reply
      |> Mqtt.Command.return_result()

    Logger.info("handle_msg: status #{inspect(status)}")
    Logger.info("handle_msg: command #{inspect(result)}")
    Logger.info("state: #{inspect(state)}")
    {:ok, state}
  end

  def handle_message(topic, msg, state) do
    Logger.info("topic != sfractal/command")
    Logger.info("#{state.name}, #{Enum.join(topic, "/")} #{inspect(msg)}")
    {:ok, state}
  end

  @impl true
  def terminate(reason, _state) do
    Logger.warn("Client has been terminated with reason: #{inspect(reason)}")
    :ok
  end
end
