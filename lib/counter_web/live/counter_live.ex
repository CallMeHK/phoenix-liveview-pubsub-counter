defmodule CounterWeb.CounterLive do
  use Phoenix.LiveView

  def mount(_session, _, socket) do
    socket = assign(socket, :count, 0)
    {:ok, socket}
  end

  def handle_params(%{"req_id" => req_id}, _uri, socket) do
    Phoenix.PubSub.subscribe(CounterWeb.PubSub, "req_id_#{req_id}")
    {:noreply,
     socket
     |> assign(:req_id, req_id)}
  end

  def handle_params(_,_,socket) do
    Phoenix.PubSub.subscribe(CounterWeb.PubSub, "req_id_default")
    {:noreply,
    socket
    |> assign(:req_id, "default")}
  end

  def render(assigns)do
    ~L"""
    <h1> Count <%= @count %></h1>
    <button phx-click="increment">+</button>
    <button  phx-click="decrement">-</button>
    """
  end

  def handle_info(%{count: count} = event, socket) do
    {:noreply, socket |> assign(:count, count)}
  end

  def handle_event("increment", _, socket) do
    count = socket.assigns.count + 1
    socket = assign(socket, :count, count)
    req_id = socket.assigns[:req_id]
    Phoenix.PubSub.broadcast(CounterWeb.PubSub, "req_id_#{req_id}", %{event: "increment", count: count})
    {:noreply, socket}
  end

  def handle_event("decrement", _, socket) do
    count = socket.assigns.count - 1
    socket = assign(socket, :count, count)
    req_id = socket.assigns[:req_id]
    Phoenix.PubSub.broadcast(CounterWeb.PubSub, "req_id_#{req_id}", %{event: "decrement", count: count})
    {:noreply, socket}
  end
end
