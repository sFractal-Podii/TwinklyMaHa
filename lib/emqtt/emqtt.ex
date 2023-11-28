defmodule Emqtt do
  use GenServer
  require Logger

  @clean_start false

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    topic = "oc2/cmd/device/t01"

    clientid =
      System.get_env("CLIENT_ID") ||
        raise """
        environment variable CLIENT_ID is missing.
        For example:
        export CLIENT_ID=sfractal2020
        """

    Logger.info("client_id is #{clientid}")

    host =
      ~c"#{System.get_env("MQTT_HOST")}" ||
        raise """
        environment variable HOST is missing.
        Examples:
        export MQTT_HOST="35.221.11.97 "
        export MQTT_HOST="mqtt.sfractal.com"
        """

    Logger.info("mqtt_host is #{host}")

    port =
      String.to_integer(
        System.get_env("MQTT_PORT") ||
          raise("""
          environment variable MQTT_PORT is missing.
          Example:
          export MQTT_PORT=1883
          """)
      )

    Logger.info("mqtt_port is #{port}")

    name =
      String.to_atom(System.get_env("USER_NAME")) ||
        raise """
        environment variable USER_NAME is missing.
        Examples:
        export USER_NAME="plug"
        """

    Logger.info("user_name is #{name}")

    emqtt_opts = [
      host: host,
      port: port,
      clientid: clientid,
      clean_start: @clean_start,
      name: name
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

  def publish(message) do
    GenServer.cast(__MODULE__, {:publish, message})
  end
end
