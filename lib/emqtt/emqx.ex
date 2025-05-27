defmodule Emqtt.Emqx do
  @moduledoc "Emqtt server responsible for handling pubsub between clients and broker"
  use GenServer
  require Logger

  alias TwinklyMaha.Oc2

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    topic = "oc2/cmd/device/t01"

    emqtt_opts = Application.get_env(:twinkly_maha, Emqtt.Emqx)

    Logger.info("Starting #{__MODULE__} with options: #{inspect(emqtt_opts)}")

    {:ok, pid} = :emqtt.start_link(emqtt_opts)

    {:ok, %{pid: pid, topic: topic}, {:continue, :start_emqtt}}
  end

  def handle_continue(:start_emqtt, %{pid: pid, topic: topic} = state) do
    {:ok, _} = :emqtt.connect(pid)

    {:ok, _, _} = :emqtt.subscribe(pid, {topic, 1})

    Logger.info(%{event: :subscribed, topic: topic})

    {:noreply, state}
  end

  def handle_cast({:publish, message}, %{topic: topic, pid: pid} = state) do
    :emqtt.publish(pid, topic, message)

    {:noreply, state}
  end

  def handle_info({:publish, publish}, state) do
    handle_publish(parse_topic(publish), publish, state)
  end

  defp handle_publish(
         ["oc2", "cmd", "device", "t01"] = topic,
         %{payload: payload},
         state
       ) do
    Logger.info(%{
      topic: Enum.join(topic, "/"),
      message: payload,
      state: state
    })

    Oc2.handle_payload(payload)

    {:noreply, state}
  end

  defp handle_publish(topic, %{payload: payload}, state) do
    Logger.info("topic != oc2/cmd/device/t01")
    Logger.info("#{Enum.join(topic, "/")} #{inspect(payload)}")
    {:noreply, state}
  end

  defp parse_topic(%{topic: topic}) do
    String.split(topic, "/", trim: true)
  end

  def publish(message) do
    GenServer.cast(__MODULE__, {:publish, message})
  end
end
