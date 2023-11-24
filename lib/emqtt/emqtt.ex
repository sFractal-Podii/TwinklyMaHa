defmodule Emqtt do
  use GenServer
  require Logger

  @host ~c"broker.emqx.io"
  @port 1883
  @clientid "sfractal2020"
  @clean_start false
  @name :emqtt
  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    topic = "oc2/cmd/device/t01"

    emqtt_opts = [
      host: @host,
      port: @port,
      clientid: @clientid,
      clean_start: @clean_start,
      name: @name
    ]

    {:ok, pid} = :emqtt.start_link(emqtt_opts)

    state = %{pid: pid, topic: topic}

    {:ok, state, {:continue, :start_emqtt}}
  end

  def handle_continue(:start_emqtt, %{pid: pid, topic: topic} = state) do
    {:ok, _} = :emqtt.connect(pid)

    {:ok, _, _} = :emqtt.subscribe(pid, {topic, 1})

    {:noreply, state}
  end

  def handle_cast({:publish, message}, %{topic: topic, pid: pid} = state) do
    :emqtt.publish(
      pid,
      topic,
      message
    )

    {:noreply, state}
  end

  def handle_info({:publish, publish}, state) do
    handle_publish(parse_topic(publish), publish, state)
  end

  defp handle_publish(
         ["oc2", "cmd", "device", "t01"] = _topic,
         %{payload: payload},
         state
       ) do
    Logger.info("topic: oc2/cmd/device/t01")
    Logger.info("msg: #{inspect(payload)}")
    # handle the message , turn led on and off

    res =
      payload
      |> Openc2.Oc2.Command.new()
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

  def publish(server, message) do
    GenServer.cast(server, {:publish, message})
  end
end
