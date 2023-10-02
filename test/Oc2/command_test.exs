defmodule CommandTest do
  use ExUnit.Case
  doctest Oc2.Command

  test "invalid json" do
    command =
      "{[this is bad"
      |> Oc2.Command.new()

    assert command.error? == true
    assert command.error_msg != nil
  end

  test "valid json1" do
    command =
      """
      {"action": "query",
      "target": {"x-sfractal-blinky:hello_world": "Hello"},
      "args": {"response_requested": "complete"}
      }
      """
      |> Oc2.Command.new()

    assert command.error? == false
    assert command.error_msg == nil
    assert command.action == "query"
    assert command.actuator == nil
    assert command.actuator_specifier == nil
    assert command.args == nil
    assert command.cmd_id == nil
    assert command.target == "x-sfractal-blinky:hello_world"
    assert command.target_specifier == "Hello"
    assert command.response == "complete"

    assert command.cmd == %{
             "action" => "query",
             "args" => %{"response_requested" => "complete"},
             "target" => %{"x-sfractal-blinky:hello_world" => "Hello"}
           }
  end

  test "check_cmd_upsteam" do
    command =
      %Oc2.Command{error?: true, error_msg: "error_msg"}
      |> Oc2.CheckOc2.check_cmd()

    assert command.error? == true
    assert command.error_msg == "error_msg"
  end

  test "missing action" do
    {:ok, jsontxt} = File.read("test/Bad-command/missing_action.json")
    command = jsontxt |> Oc2.Command.new()
    assert command.error? == true
    assert command.error_msg == "no action in command"
  end

  test "missing target" do
    command =
      """
      {"action": "query",
      "args": {"response_requested": "complete"},
      "command_id": "commandIDtest"
      }
      """
      |> Oc2.Command.new()

    assert command.error? == true
    assert command.error_msg == "no target in command"
  end

  test "extra top level" do
    {:ok, jsontxt} = File.read("test/Bad-command/xtra_top_level.json")
    command = jsontxt |> Oc2.Command.new()
    assert command.error? == true
    assert command.error_msg == "extra top level fields in command"
  end

  test "bad action" do
    {:ok, jsontxt} = File.read("test/Bad-command/bad_action.json")
    command = jsontxt |> Oc2.Command.new()
    assert command.error? == true
    assert command.error_msg == "bad action"
  end

  test "wrong_target_structure" do
    {:ok, jsontxt} = File.read("test/Bad-command/wrong_target_structure.json")
    command = jsontxt |> Oc2.Command.new()
    assert command.error? == true
    assert command.error_msg == "bad target"
  end

  test "two targets" do
    {:ok, jsontxt} = File.read("test/Bad-command/two_targets.json")
    command = jsontxt |> Oc2.Command.new()
    assert command.error? == true
    assert command.error_msg == "bad target"
  end

  test "unknown target" do
    {:ok, jsontxt} = File.read("test/Bad-command/unknown_target.json")
    command = jsontxt |> Oc2.Command.new()
    assert command.error? == true
    assert command.error_msg == "invalid target \"unknown\""
  end

  test "command id" do
    {:ok, jsontxt} = File.read("test/Good-command/profiles.json")
    command = jsontxt |> Oc2.Command.new()

    assert command.error? == false
    assert command.cmd_id == "randomcommandid"
  end

  test "bad cmd id" do
    {:ok, jsontxt} = File.read("test/Bad-command/bad_cmd_id.json")
    command = jsontxt |> Oc2.Command.new()
    assert command.error? == true
    assert command.error_msg == "command_id is not string"
  end

  test "default response" do
    {:ok, jsontxt} = File.read("test/Good-command/default_response.json")
    command = jsontxt |> Oc2.Command.new()
    assert command.error? == false
    assert command.response == "complete"
  end

  test "check complete response requested" do
    {:ok, jsontxt} = File.read("test/Good-command/version.json")
    command = jsontxt |> Oc2.Command.new()
    assert command.error? == false
    assert command.response == "complete"
  end

  test "check none response requested" do
    {:ok, jsontxt} = File.read("test/Good-command/no_response.json")
    command = jsontxt |> Oc2.Command.new()
    assert command.error? == false
    assert command.response == "none"
  end

  test "check unused response requested" do
    {:ok, jsontxt} = File.read("test/Bad-command/unused_response.json")
    command = jsontxt |> Oc2.Command.new()
    assert command.error? == true
    assert command.error_msg == "not handling response_requested = \"ack\" "
  end

  test "check two args" do
    {:ok, jsontxt} = File.read("test/Bad-command/two_arg.json")
    command = jsontxt |> Oc2.Command.new()

    assert command.error? == true

    assert command.error_msg ==
             "not one arg: %{\"response_requested\" => \"complete\", \"start_time\" => \"now\"}"
  end

  test "check unknown arg" do
    {:ok, jsontxt} = File.read("test/Bad-command/unknown_arg.json")
    command = jsontxt |> Oc2.Command.new()

    assert command.error? == true
    assert command.error_msg == "unknown arg %{\"unknown_arg\" => \"complete\"}"
  end

  test "version.json" do
    {:ok, jsontxt} = File.read("test/Good-command/version.json")
    command = jsontxt |> Oc2.Command.new()

    assert command.error? == false
    assert command.error_msg == nil
    assert command.action == "query"
    assert command.actuator == nil
    assert command.actuator_specifier == nil
    assert command.args == nil
    assert command.cmd_id == nil
    assert command.target == "features"
    assert command.target_specifier == ["versions"]
    assert command.response == "complete"
  end

  test "sbom.json" do
    {:ok, jsontxt} = File.read("test/Good-command/sbom1.json")
    command = jsontxt |> Oc2.Command.new()

    assert command.error? == false
    assert command.error_msg == nil
    assert command.action == "query"
    assert command.actuator == nil
    assert command.actuator_specifier == nil
    assert command.args == nil
    assert command.cmd_id == nil
    assert command.target == "sbom"
    assert command.target_specifier == %{"type" => ["cyclonedx", "spdx", "swid"]}
    assert command.response == "complete"
  end

  test "pairs.json" do
    {:ok, jsontxt} = File.read("test/Good-command/pairs.json")
    command = jsontxt |> Oc2.Command.new()

    assert command.error? == false
    assert command.error_msg == nil
    assert command.action == "query"
    assert command.actuator == nil
    assert command.actuator_specifier == nil
    assert command.args == nil
    assert command.cmd_id == nil
    assert command.target == "features"
    assert command.target_specifier == ["pairs"]
    assert command.response == "complete"
  end

  test "profiles.json" do
    {:ok, jsontxt} = File.read("test/Good-command/profiles.json")
    command = jsontxt |> Oc2.Command.new()

    assert command.error? == false
    assert command.error_msg == nil
    assert command.action == "query"
    assert command.actuator == nil
    assert command.actuator_specifier == nil
    assert command.args == nil
    assert command.cmd_id == "randomcommandid"
    assert command.target == "features"
    assert command.target_specifier == ["profiles"]
    assert command.response == "complete"
  end

  test "led-off.json" do
    {:ok, jsontxt} = File.read("test/Good-command/led-off.json")
    command = jsontxt |> Oc2.Command.new()

    assert command.error? == false
    assert command.error_msg == nil
    assert command.action == "set"
    assert command.actuator == nil
    assert command.actuator_specifier == nil
    assert command.args == nil
    assert command.cmd_id == nil
    assert command.target == "led"
    assert command.target_specifier == "off"
    assert command.response == "complete"
  end

  test "led-on.json" do
    {:ok, jsontxt} = File.read("test/Good-command/led-on.json")
    command = jsontxt |> Oc2.Command.new()

    assert command.error? == false
    assert command.error_msg == nil
    assert command.action == "set"
    assert command.actuator == nil
    assert command.actuator_specifier == nil
    assert command.args == nil
    assert command.cmd_id == nil
    assert command.target == "led"
    assert command.target_specifier == "on"
    assert command.response == "complete"
  end

  test "led-rainbow.json" do
    {:ok, jsontxt} = File.read("test/Good-command/led-rainbow.json")
    command = jsontxt |> Oc2.Command.new()

    assert command.error? == false
    assert command.error_msg == nil
    assert command.action == "set"
    assert command.actuator == nil
    assert command.actuator_specifier == nil
    assert command.args == nil
    assert command.cmd_id == nil
    assert command.target == "led"
    assert command.target_specifier == "rainbow"
    assert command.response == "complete"
  end

  test "led-red.json" do
    {:ok, jsontxt} = File.read("test/Good-command/led-red.json")
    command = jsontxt |> Oc2.Command.new()

    assert command.error? == false
    assert command.error_msg == nil
    assert command.action == "set"
    assert command.actuator == nil
    assert command.actuator_specifier == nil
    assert command.args == nil
    assert command.cmd_id == nil
    assert command.target == "led"
    assert command.target_specifier == "red"
    assert command.response == "complete"
  end
end
