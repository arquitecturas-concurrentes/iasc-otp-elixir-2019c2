defmodule ClientSupervisor do
  use DynamicSupervisor

  def start_link([]) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    # We use now the one_for_one strategy instead of the simple_one_for_one
    # Dynamic supervision is now much easier to initialize
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  # Start a Client process and add it to supervision
  def add_client(client_username, server_id) do
    #now we can use an spec instead of just passong the Enumerable with the initial arguments, the module is explicitly used here instead of defined in the init.
    child_spec = {Client, {client_username, server_id}}
    DynamicSupervisor.start_child(__MODULE__, child_spec)
    # before 
    #DynamicSupervisor.start_child(__MODULE__, [{client_username, server_id}])
  end

  # Terminate a Client process and remove it from supervision
  def remove_client(client_pid) do
    DynamicSupervisor.terminate_child(__MODULE__, client_pid)
  end

  # Check the supervised processes
  def children do
    DynamicSupervisor.which_children(__MODULE__)
  end

  def count_children do
    DynamicSupervisor.count_children(__MODULE__)
  end
end
