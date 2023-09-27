defmodule DoSetTest do
  use ExUnit.Case

  test "check_cmd_upsteam" do
    command =
      %Openc2.Oc2.Command{error?: true, error_msg: "error_msg"}
      |> Oc2.DoSet.do_cmd()

    assert command.error? == true
    assert command.error_msg == "error_msg"
  end

  test "wrong action" do
    command =
      %Openc2.Oc2.Command{error?: false, action: "query"}
      |> Oc2.DoSet.do_cmd()

    assert command.error? == true
    assert command.error_msg == "wrong action in command"
  end

  test "wrong led color" do
    command =
      %Openc2.Oc2.Command{
        error?: false,
        action: "set",
        target: "led",
        target_specifier: "badcolor"
      }
      |> Oc2.DoSet.do_cmd()

    assert command.error? == true
    assert command.error_msg == "invalid color"
  end

  test "rainbow" do
    command =
      %Openc2.Oc2.Command{
        error?: false,
        action: "set",
        target: "led",
        target_specifier: "rainbow"
      }
      |> Oc2.DoSet.do_cmd()

    assert command.error_msg == nil
    assert command.error? == false
    assert command.response.status == 200
  end

  test "red" do
    command =
      %Openc2.Oc2.Command{
        error?: false,
        action: "set",
        target: "led",
        target_specifier: "red"
      }
      |> Oc2.DoSet.do_cmd()

    assert command.error_msg == nil
    assert command.error? == false
    assert command.response.status == 200
  end

  test "led off" do
    command =
      %Openc2.Oc2.Command{
        error?: false,
        action: "set",
        target: "led",
        target_specifier: "off"
      }
      |> Oc2.DoSet.do_cmd()

    assert command.error_msg == nil
    assert command.error? == false
    assert command.response.status == 200
  end

  test "led on" do
    command =
      %Openc2.Oc2.Command{
        error?: false,
        action: "set",
        target: "led",
        target_specifier: "on"
      }
      |> Oc2.DoSet.do_cmd()

    assert command.error_msg == nil
    assert command.error? == false
    assert command.response.status == 200
  end
end
