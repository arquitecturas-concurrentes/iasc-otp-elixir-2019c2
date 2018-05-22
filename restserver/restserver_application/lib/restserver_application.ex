defmodule RESTServer.Application do
  use Application

  def start(_type, _args) do
    IO.puts "App started"
    {:ok, sup_pid} = RESTServer.Supervisor.start_link

    {:ok, worker_pid} = Supervisor.start_child(sup_pid, :server)
  end
end