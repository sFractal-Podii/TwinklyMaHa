defmodule Mqtt.Command do
  @moduledoc """
  Documentation for `Command` contains helper functions for decoding
  and responding to OpenC2 cmds:
  - new - initialize struct and validate command
  - do_cmd - execute the command
  - return_result - respond to OC2 producer
  """

  require Logger

  @doc """
  return result
  """
  def return_result(%Openc2.Oc2.Command{error?: true} = command) do
    ## something went wrong upstream, so return "oops"
    e1 = "Error: "
    e2 = inspect(command.error_msg)
    error_msg = e1 <> " " <> e2
    Logger.debug(error_msg)
    Tortoise.publish("sFractal/response", "oops")
    {:error, error_msg}
  end

  def return_result(%Openc2.Oc2.Command{response: nil} = command) do
    ## no response
    {:ok, command}
  end

  def return_result(command) do
    Logger.debug("return: ok #{inspect(command.response)}")
    response = Jason.encode(command.response)
    Logger.debug("json: #{inspect(response)}")
    Tortoise.publish("sFractal/response", response)
    {:ok, command}
  end
end
