defmodule Oc2.DoSet do
  @moduledoc """
  Documentation for `Set` contains helper functions for
  blah blah
  """

  require Logger

  @colors ["violet", "indigo", "blue", "green", "yellow", "orange", "red"]

  @topic "leds"

  @doc """
  do_cmd executes the action
  matching on action/target
  end
  """
  def do_cmd(%Oc2.Command{error?: true} = command) do
    ## something went wrong upstream, pass along
    command
  end

  def do_cmd(%Oc2.Command{action: action}) when action != "set" do
    ## should always be action=set
    Oc2.Command.return_error("wrong action in command")
  end

  def do_cmd(%Oc2.Command{target_specifier: color, target: "led"} = command) do
    set_color(color, command)
  end

  def do_cmd(command) do
    ## should not have gotten here
    Logger.debug("do_cmd #{inspect(command)}")
    Oc2.Command.return_error("invalid action/target or target/specifier pair")
  end

  defp set_color("rainbow", command) do
    Phoenix.PubSub.broadcast(TwinklyMaha.PubSub, @topic, "rainbow")
    %Oc2.Command{command | response: %{status: 200}}
  end

  defp set_color("off", command) do
    Phoenix.PubSub.broadcast(TwinklyMaha.PubSub, @topic, "off")
    %Oc2.Command{command | response: %{status: 200}}
  end

  defp set_color("on", command) do
    Phoenix.PubSub.broadcast(TwinklyMaha.PubSub, @topic, "on")
    %Oc2.Command{command | response: %{status: 200}}
  end

  defp set_color(color, command) do
    if color in @colors do
      Phoenix.PubSub.broadcast(TwinklyMaha.PubSub, @topic, color)
      %Oc2.Command{command | response: %{status: 200}}
    else
      Oc2.Command.return_error("invalid color")
    end
  end
end
