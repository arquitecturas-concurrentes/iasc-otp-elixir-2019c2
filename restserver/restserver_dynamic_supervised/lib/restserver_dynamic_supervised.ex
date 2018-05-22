defmodule RESTServer.Supervisor do
  use DynamicSupervisor

  ## Client API

  def start_link do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_restserver(sup, name \\ :bleh) do
    spec = {RESTServer, name}
    DynamicSupervisor.start_child(sup, spec)
  end

  def remove_restserver(sup, server_id) do
    DynamicSupervisor.terminate_child(sup, server_id)
  end

  def remove_all_children(sup) do
    for {_, child, _, _} <- RESTServer.Supervisor.children do
      RESTServer.Supervisor.remove_restserver(sup, child)
    end
  end

  ## Server Callbacks

  @impl true
  def init([]) do
    #children = [
    #   %{id: RESTServer, start: {RESTServer, :start_link, []})
    #]

    #Supervisor.init(children, strategy: :simple_one_for_one)

    DynamicSupervisor.init(
      strategy: :one_for_one,
      extra_arguments: []
    )
  end

  ## Helper functions
  # Check the supervised processes
  def children do
    DynamicSupervisor.which_children(__MODULE__)
  end

  def children_for(sup) do
    DynamicSupervisor.which_children(sup)
  end

  def count_children do
    DynamicSupervisor.count_children(__MODULE__)
  end

end
