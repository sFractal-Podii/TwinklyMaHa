defmodule Oc2.CheckOc2 do
  @moduledoc """
  `Oc2.CheckOc2` contains helper functions for decoding
  and responding to OpenC2 commands:
  - new - initialize struct
  - chk_cmd - validate command
  """

  @actions ["query", "set", "cancel", "allow", "deny"]
  @targets [
    "sbom",
    "features",
    "x-sfractal-blinky:hello_world",
    "x-sfractal-blinky:led",
    "ipv4_net",
    "ipv6_net"
  ]
  @top_level ["action", "target", "args", "actuator", "command_id"]
  @response ["none", "complete"]
  @action_target_pairs [
    {"query", "features"},
    {"query", "sbom"},
    {"query", "blinky:hello_world"},
    {"set", "blinky:led"},
    {"set", "x-sfractal-blinky:led"},
    {"allow", "ipv4_net"},
    {"allow", "ipv6_net"},
    {"deny", "ipv4_net"},
    {"deny", "ipv6_net"}
  ]

  require Logger

  @doc """
  new intializes the command struct
  """
  def new({:ok, cmd}) do
    %Oc2.Command{cmd: cmd, error?: false}
  end

  def new({_status, error_msg}) do
    %Oc2.Command{error?: true, error_msg: error_msg}
  end

  @doc """
  check_cmd checks the decoded json (now elixir terms) for
  compliance with the openc2 specification
  """
  def check_cmd(%Oc2.Command{error?: true} = command) do
    ## upstream error, pass it on
    command
  end

  def check_cmd(command) do
    Logger.debug("check_oc2:cmd is #{inspect(command.cmd)}")

    command
    |> check_top
    |> check_action
    |> get_target
    |> check_target
    |> check_id
    |> check_args
    |> log_cmd
  end

  defp check_top(%Oc2.Command{error?: true} = command) do
    ## upstream error, pass it on
    command
  end

  defp check_top(command) do
    tops = Map.keys(command.cmd)

    cond do
      ## is action missing?
      "action" not in tops ->
        Oc2.Command.return_error("no action in command")

      ## is target missing?
      "target" not in tops ->
        Oc2.Command.return_error("no target in command")

      ## extra top level fields
      0 != length(tops -- @top_level) ->
        Oc2.Command.return_error("extra top level fields in command")

      true ->
        ## passed checks
        Logger.debug("check_top: passed")
        # pass command struct to next step
        command
    end
  end

  defp check_action(%Oc2.Command{error?: true} = command) do
    ## upstream error, pass it on
    command
  end

  defp check_action(command) do
    action = command.cmd["action"]
    Logger.debug("check_action: action #{action}")

    if action in @actions do
      # return struct with action updated
      %Oc2.Command{command | action: action}
    else
      # return error
      Oc2.Command.return_error("bad action")
    end
  end

  defp get_target(%Oc2.Command{error?: true} = command) do
    ## upstream error, pass it on
    command
  end

  defp get_target(command) do
    whole_target = command.cmd["target"]
    Logger.debug("whole_target: #{inspect(whole_target)}")

    if good_target?(whole_target) do
      [target] = Map.keys(whole_target)
      target_specifier = whole_target[target]
      %Oc2.Command{command | target: target, target_specifier: target_specifier}
    else
      Oc2.Command.return_error("bad target")
    end
  end

  defp check_target(%Oc2.Command{error?: true} = command) do
    ## upstream error, pass it on
    command
  end

  defp check_target(command) do
    if command.target in @targets do
      if {command.action, command.target} in @action_target_pairs do
        # valid so continue
        command
      else
        Oc2.Command.return_error(
          "invalid action:target  #{inspect(command.cmd)} #{inspect(command.target)}"
        )
      end
    else
      Oc2.Command.return_error("invalid target #{inspect(command.target)}")
    end
  end

  defp check_id(%Oc2.Command{error?: true} = command) do
    ## upstream error, pass it on
    command
  end

  defp check_id(command) do
    if Map.has_key?(command.cmd, "command_id") do
      command_id = command.cmd["command_id"]
      Logger.debug("command_id #{inspect(command_id)}")

      if is_binary(command_id) do
        %Oc2.Command{command | cmd_id: command_id}
      else
        # illegal type
        Oc2.Command.return_error("command_id is not string")
      end
    else
      # no command id so continue
      command
    end
  end

  defp check_args(%Oc2.Command{error?: true} = command) do
    ## upstream error, pass it on
    command
  end

  defp check_args(command) do
    cond do
      not Map.has_key?(command.cmd, "args") ->
        # no args but need to default response_requested
        %Oc2.Command{command | response: "complete"}

      not has_only_one_key?(command.cmd["args"]) ->
        # implementation only supports one arg at moment
        Oc2.Command.return_error("not one arg: #{inspect(command.cmd["args"])}")

      not Map.has_key?(command.cmd["args"], "response_requested") ->
        # only handling the response_requested arg for now
        Oc2.Command.return_error("unknown arg #{inspect(command.cmd["args"])}")

      command.cmd["args"]["response_requested"] in @response ->
        %Oc2.Command{command | response: command.cmd["args"]["response_requested"]}

      true ->
        Oc2.Command.return_error(
          "not handling response_requested = #{inspect(command.cmd["args"]["response_requested"])} "
        )
    end
  end

  defp has_only_one_key?(a_map) do
    ## return true if one key, otherwise false
    [_h | t] = Map.keys(a_map)
    t == []
  end

  defp good_target?(a_map) do
    # validate target is a map, with only one key
    cond do
      not is_map(a_map) ->
        false

      not has_only_one_key?(a_map) ->
        false

      true ->
        true
    end
  end

  defp log_cmd(command) do
    Logger.info("#{inspect(command)}")
    command
  end
end
