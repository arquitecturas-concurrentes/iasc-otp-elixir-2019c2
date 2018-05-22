defmodule RESTServer do
  use GenServer

  ## Client API

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, [name: name])
  end

  def get(server, url) do
    GenServer.call(server, {:get, url})
  end

  def post(server, url, body) do
    GenServer.cast(server, {:post, url, body})
  end

  def put(server, url, body) do
    GenServer.cast(server, {:put, url, body})
  end

  def delete(server, url) do
    GenServer.cast(server, {:delete, url})
  end

  def break(server) do
    Process.exit(server, :shutdown)
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:get, url}, _from, state) do
    if Map.has_key?(state, url) do
      {:reply, {:ok, Map.get(state, url)}, state}
    else
      {:reply, {:ok, :not_found}, state}
    end
  end

  def handle_cast({:post, url, body}, state) do
    {:noreply, Map.put(state, url, body)}
  end

  def handle_cast({:put, url, body}, state) do
    {:noreply, Map.put(state, url, body)}
  end

  def handle_cast({:delete, url}, state) do
    {:noreply, Map.delete(state, url)}
  end

  def handle_info(msg, state) do
    IO.puts "Message not understood :("
    {:noreply, state}
  end
end
