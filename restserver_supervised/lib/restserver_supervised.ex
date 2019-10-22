defmodule RESTServer.Supervisor do
  use Supervisor

  ## Client API

  def start_link(name) do
    Supervisor.start_link(__MODULE__, name, name: __MODULE__)
  end

  def start_restserver(sup, state \\ []) do
    {:ok, pid} = Supervisor.start_child(sup, state)
    pid
  end

  def children(sup) do
    Supervisor.which_children(sup)
  end

  ## Server Callbacks

  @impl true
  def init(name) do
    #Supervised.Spec now deprcated
    #children = [
    #  worker(RESTServer, [], restart: :transient)
    #]

    children = [
      # The Stack is a child started via Stack.start_link([:hello])
      %{
        id: MyRESTServer,
        start: {RESTServer, :start_link, [name]},
        restart: :transient
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
    ##....max_restarts: 3, max_seconds: 5)
  end

end
