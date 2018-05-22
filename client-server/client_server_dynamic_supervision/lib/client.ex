defmodule Client do
  use GenServer

  def init({client_username, server_id}) do
    {:ok, %{name: client_username, server_id: server_id}}
  end

  # Insert this start_link/2 method, which intercepts the extra `[]`
  # argument from the Supervisor and molds it back to correct form.
  def start_link([], {client_username, server_id}) do
    start_link({client_username, server_id})
  end

  def start_link({client_username, server_id}) do
    GenServer.start_link(
      __MODULE__,
      {client_username, server_id},
      name: {:global, "client:#{client_username}"}
    )
  end

  def get(pid) do
    GenServer.call(pid, :get)
  end

  def handle_call(:get, _from, state) do
    {:reply, {:ok, state}, state}
  end
end