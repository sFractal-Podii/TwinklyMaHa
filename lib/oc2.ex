defmodule TwinklyMaha.Oc2 do
  @moduledoc """
  Oc2 keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias Openc2.Oc2.Command
  require Logger

  def handle_payload(payload) do
    res =
      payload
      |> Openc2.Oc2.Command.new()
      |> Openc2.Oc2.Command.do_cmd()
      |> Mqtt.Command.return_result()

    case res do
      {:ok, %Command{action: "set"} = command} ->
        Phoenix.PubSub.broadcast(TwinklyMaha.PubSub, "leds", command.target_specifier)
        Logger.info(%{status: :ok, command: command})

      {:ok, %Command{action: "query"} = command} ->
        [target_specifier] = command.target_specifier

        Phoenix.PubSub.broadcast(
          TwinklyMaha.PubSub,
          "query",
          {target_specifier, command.response}
        )

        Logger.info(%{status: :ok, command: command})

      {:error, msg} ->
        Logger.error(%{status: :error, message: msg})
    end
  end
end
