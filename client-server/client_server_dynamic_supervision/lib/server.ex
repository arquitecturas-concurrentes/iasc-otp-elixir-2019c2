defmodule Server do
  use GenServer

  def init(server_id) do
    {:ok, %{server_id: server_id}}
  end

  def start_link(server_id) do
    GenServer.start_link(__MODULE__, server_id, name: {:global, "server:#{server_id}"})
  end

  #call method to add a new client and make a "connection"
  #def handle_call({:add_client, client_username}, _from, %{server_id: server_id} = state) do
    # Uh oh, we started this process but it's not under supervision!
    #start_status = Client.start_link({client_username, server_id})
    #{:reply, start_status, state}
  #end

  def handle_call({:add_client, client_username}, _from, %{server_id: server_id} = state) do
    #Call the add of a client through a Supervisor instead of a Client
    start_status = ClientSupervisor.add_client(client_username, server_id)
    {:reply, start_status, state}  
  end

  #helper functions
  def add_client(pid, client_username) do
    GenServer.call(pid, {:add_client, client_username})
  end

end