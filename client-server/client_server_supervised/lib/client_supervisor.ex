defmodule ClientSupervisor do
  use Supervisor

  def start_link([]) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Supervisor.init([Client], strategy: :simple_one_for_one)
  end

  # Start a Client process and add it to supervision
  def add_client(client_username, server_id) do
    Supervisor.start_child(__MODULE__, [{client_username, server_id}])
  end

  # Terminate a Client process and remove it from supervision
  def remove_client(client_pid) do
    Supervisor.terminate_child(__MODULE__, client_pid)
  end

  # Check the supervised processes
  def children do
    Supervisor.which_children(__MODULE__)
  end

  def count_children do
    Supervisor.count_children(__MODULE__)
  end
end