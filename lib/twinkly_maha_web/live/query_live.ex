defmodule TwinklyMahaWeb.QueryLive do
  use TwinklyMahaWeb, :live_view

  require Logger

  @topic "query"

  @impl true
  def mount(_params, _session, socket) do
    ## subscribe to pubsub topic
    TwinklyMahaWeb.Endpoint.subscribe(@topic)
    {:ok, assign(socket, query_response: %{})}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div>
      <pre><%= Jason.encode!(@query_response, pretty: true) %></pre>
    </div>
    """
  end

  @impl true
  def handle_info({"profiles", response}, socket) do
    Logger.debug("tlive:hand.info - profile")
    {:noreply, assign(socket, query_response: response)}
  end

  @impl true
  def handle_info(event, socket) do
    Logger.debug("tlive:hand.info - #{event}")
    {:noreply, socket}
  end
end
