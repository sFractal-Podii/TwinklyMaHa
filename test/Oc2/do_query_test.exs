defmodule DoQueryTest do
  use ExUnit.Case

  test "check_cmd_upsteam" do
    command =
      %Openc2.Oc2.Command{error?: true, error_msg: "error_msg"}
      |> Oc2.DoQuery.do_cmd()

    assert command.error? == true
    assert command.error_msg == "error_msg"
  end

  test "wrong action" do
    command =
      %Openc2.Oc2.Command{error?: false, action: "set"}
      |> Oc2.DoQuery.do_cmd()

    assert command.error? == true
    assert command.error_msg == "wrong action in command"
  end

  test "hello world" do
    command =
      %Openc2.Oc2.Command{
        error?: false,
        action: "query",
        target: "x-sfractal-blinky:hello_world",
        target_specifier: "Hello"
      }
      |> Oc2.DoQuery.do_cmd()

    assert command.error? == false
    assert command.response == "Hello World"
  end

  test "bad hello world" do
    command =
      %Openc2.Oc2.Command{
        error?: false,
        action: "query",
        target: "x-sfractal-blinky:hello_world",
        target_specifier: "hello"
      }
      |> Oc2.DoQuery.do_cmd()

    assert command.error? == true
    assert command.error_msg == "Hello World incorrect specifier"
  end

  test "invalid action/target" do
    command =
      %Openc2.Oc2.Command{
        error?: false,
        action: "query",
        target: "hello_world",
        target_specifier: "hello"
      }
      |> Oc2.DoQuery.do_cmd()

    assert command.error? == true
    assert command.error_msg == "invalid action/target or target/specifier pair"
  end

  test "good_sbom" do
    command =
      %Openc2.Oc2.Command{
        error?: false,
        action: "query",
        target: "sbom",
        target_specifier: %{type: ["cyclonedx", "spdx", "swid"]}
      }
      |> Oc2.DoQuery.do_cmd()

    assert command.error? == false
    assert command.response.status == 200
    assert command.response.results.sbom.depth == "one-hop"
    assert command.response.results.sbom.manifest.mime_type == "application/cyclonedx+xml"
    assert command.response.results.sbom.type == "CycloneDX"
  end

  test "sbom_swid" do
    command =
      %Openc2.Oc2.Command{
        error?: false,
        action: "query",
        target: "sbom",
        target_specifier: %{type: ["swid"]}
      }
      |> Oc2.DoQuery.do_cmd()

    assert command.error? == true
    assert command.error_msg == "invalid target specifier"
  end

  test "sbom_not_list" do
    command =
      %Openc2.Oc2.Command{
        error?: false,
        action: "query",
        target: "sbom",
        target_specifier: %{type: "cyclonedx"}
      }
      |> Oc2.DoQuery.do_cmd()

    assert command.error? == true
    assert command.error_msg == "invalid target specifier"
  end

  test "sbom_not_type" do
    command =
      %Openc2.Oc2.Command{
        error?: false,
        action: "query",
        target: "sbom",
        target_specifier: %{nottype: "cyclonedx"}
      }
      |> Oc2.DoQuery.do_cmd()

    assert command.error? == true
    assert command.error_msg == "invalid target specifier"
  end

  test "sbom_not_map" do
    command =
      %Openc2.Oc2.Command{
        error?: false,
        action: "query",
        target: "sbom",
        target_specifier: "cyclonedx"
      }
      |> Oc2.DoQuery.do_cmd()

    assert command.error? == true
    assert command.error_msg == "invalid target specifier"
  end

  test "feature not list" do
    command =
      %Openc2.Oc2.Command{
        error?: false,
        action: "query",
        target: "features",
        target_specifier: "version"
      }
      |> Oc2.DoQuery.do_cmd()

    assert command.error? == true
    assert command.error_msg == "invalid target specifier"
  end

  test "invalid feature" do
    command =
      %Openc2.Oc2.Command{
        error?: false,
        action: "query",
        target: "features",
        target_specifier: ["nonfeature"]
      }
      |> Oc2.DoQuery.do_cmd()

    assert command.error? == true
    assert command.error_msg == "invalid features"
  end

  test "empty feature" do
    command =
      %Openc2.Oc2.Command{
        error?: false,
        action: "query",
        target: "features",
        target_specifier: []
      }
      |> Oc2.DoQuery.do_cmd()

    assert command.error? == false
    assert command.response.status == 200
  end

  test "versions" do
    command =
      %Openc2.Oc2.Command{
        error?: false,
        action: "query",
        target: "features",
        target_specifier: ["versions"]
      }
      |> Oc2.DoQuery.do_cmd()

    assert command.error? == false
    assert command.response.status == 200
    assert command.response.results.versions == ["0.5.2"]
  end

  test "pairs" do
    command =
      %Openc2.Oc2.Command{
        error?: false,
        action: "query",
        target: "features",
        target_specifier: ["pairs"]
      }
      |> Oc2.DoQuery.do_cmd()

    assert command.error? == false
    assert command.response.status == 200
    assert Enum.member?(command.response.results.pairs.query, :features)
    assert Enum.member?(command.response.results.pairs.query, :sbom)
    assert Enum.member?(command.response.results.pairs.query, :hello_world)
    assert Enum.member?(command.response.results.pairs.set, :led)
  end

  test "rate_limit" do
    command =
      %Openc2.Oc2.Command{
        error?: false,
        action: "query",
        target: "features",
        target_specifier: ["rate_limit"]
      }
      |> Oc2.DoQuery.do_cmd()

    assert command.error? == false
    assert command.response.status == 200
    assert command.response.results.rate_limit == 100_000
  end

  test "profiles" do
    command =
      %Openc2.Oc2.Command{
        error?: false,
        action: "query",
        target: "features",
        target_specifier: ["profiles"]
      }
      |> Oc2.DoQuery.do_cmd()

    assert command.error? == false
    assert command.response.status == 200
    assert command.response.results.profiles == "Duncan needs to do profiles output"
  end

  test "multifeature" do
    command =
      %Openc2.Oc2.Command{
        error?: false,
        action: "query",
        target: "features",
        target_specifier: ["rate_limit", "profiles", "pairs"]
      }
      |> Oc2.DoQuery.do_cmd()

    assert command.error? == false
    assert command.response.status == 200
    assert command.response.results.rate_limit == 100_000
    assert command.response.results.profiles
    assert Enum.member?(command.response.results.pairs.query, :sbom)
  end
end
