defmodule EmqttSupervisor do
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def start_emqtt(args \\ %{broker: "emqx"}) do
    IO.inspect(args)
    # If MyWorker is not using the new child specs, we need to pass a map:
    spec = %{id: args[:broker], start: {Emqtt, :start_link, [args]}, restart: :temporary}

    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @impl true
  def init(init_arg) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      extra_arguments: [init_arg]
    )
  end
end
