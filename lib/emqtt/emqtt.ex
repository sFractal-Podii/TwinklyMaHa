defmodule Emqtt do
  @moduledoc "Emqtt server responsible for handling pubsub between clients and broker"
  use GenServer
  alias Openc2.Oc2.Command
  require Logger

  @clean_start false

  # client

  def start_link(args \\ %{broker: "emqx"}) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def publish(message) do
    GenServer.cast(__MODULE__, {:publish, message})
  end

  # server

  def init(args) do
    topic = "oc2/cmd/device/t01"

    emqtt_opts = configuration(args)
    {:ok, pid} = :emqtt.start_link(emqtt_opts)
    IO.inspect(pid, label: "============================emqtt")

    state = %{pid: pid, topic: topic}

    {:ok, state, {:continue, :start_emqtt}}
  end

  def handle_continue(:start_emqtt, %{pid: pid, topic: topic} = state) do
    {:ok, _} = :emqtt.connect(pid) |> IO.inspect(label: "connecting????????????//")

    {:ok, _, _} =
      :emqtt.subscribe(pid, {topic, 1}) |> IO.inspect(label: "emqtt.subscribe????????????//")

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
      {:ok, %Command{action: "set"} = command} ->
        Phoenix.PubSub.broadcast(TwinklyMaha.PubSub, "leds", command.target_specifier)
        Logger.info("handle_msg: status :ok")
        Logger.info("handle_msg: command #{inspect(command)}")
        Logger.info("state: #{inspect(state)}")

      {:ok, %Command{action: "query"} = command} ->
        [target_specifier] = command.target_specifier

        Phoenix.PubSub.broadcast(
          TwinklyMaha.PubSub,
          "query",
          {target_specifier, command.response}
        )

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

  defp configuration(%{broker: "emqx"}) do
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

    [
      host: host,
      port: port,
      clientid: clientid,
      clean_start: @clean_start,
      name: name
    ]
  end

  defp configuration(%{broker: "hivemq"}) do
    clientid =
      System.get_env("HIVEMQ_CLIENT_ID") ||
        raise """
        environment variable HIVEMQ_CLIENT_ID is missing.
        For example:
        export HIVEMQ_CLIENT_ID=sfractal2020
        """

    Logger.info("client_id is #{clientid}")

    host =
      ~c"#{System.get_env("HIVEMQ_HOST")}" ||
        raise """
        environment variable HIVEMQ_HOST is missing.
        Examples:
        export HIVEMQ_HOST="35.221.11.97 "
        export HIVEMQ_HOST="mqtt.sfractal.com"
        """

    Logger.info("mqtt_host is #{host}")

    port =
      String.to_integer(
        System.get_env("HIVEMQ_PORT") ||
          raise("""
          environment variable HIVEMQ_PORT is missing.
          Example:
          export HIVEMQ_PORT=1883
          """)
      )

    Logger.info("mqtt_port is #{port}")

    name =
      String.to_atom(System.get_env("HIVEMQ_USER_NAME")) ||
        raise """
        environment variable HIVEMQ_USER_NAME is missing.
        Examples:
        export HIVEMQ_USER_NAME="plug"
        """

    Logger.info("user_name is #{name}")

    [
      host: host,
      port: port,
      clientid: clientid,
      clean_start: @clean_start,
      name: name
    ]
  end

  defp configuration(_broker), do: []
end

# Pseudo:
# - We have a MQTT client for Elixir in  place
# - can use different broker configuration
# 1. Start the Emqtt client when the broker option is selected
# 2. Pass the option as argument to know which one is selected
# 3. From the option selected fetch the environment variables for broker configuration
# 4. Then call the publish function to publish message
# 5. Do we terminate after completing the job??

# Steps:

# Create a file(mqtt_client.ex)
# start the emqtt 
# publish

# TODO
# 1. refactor if already started
# 2. Test with openc2test
# 3. Terminate if already started
