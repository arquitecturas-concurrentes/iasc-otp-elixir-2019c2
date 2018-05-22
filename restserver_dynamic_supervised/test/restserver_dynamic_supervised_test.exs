defmodule RestserverDynamicSupervisedTest do
  use ExUnit.Case

  test "start supervised worker" do
    {:ok, sup_pid} = RESTServer.Supervisor.start_link

    {:ok, worker_pid} = RESTServer.Supervisor.start_restserver(sup_pid, :server)

    assert RESTServer.get(:server, "/document") == {:ok, :not_found}

    assert RESTServer.post(:server, "/document", "aaa") == :ok

    assert RESTServer.get(:server, "/document") == {:ok, "aaa"}
  end

  test "broke supervised worker" do
    {:ok, sup_pid} = RESTServer.Supervisor.start_link

    {:ok, worker_pid} = RESTServer.Supervisor.start_restserver(sup_pid, :server)

    assert RESTServer.Supervisor.children_for(sup_pid) == [{:undefined, worker_pid, :worker, [RESTServer]}]

    # Finish the server in an abnormal way
    GenServer.stop(:server, :kill)
    :timer.sleep(500)
    assert Process.alive?(Process.whereis(:server))

    # Finish the server in a normal way
    RESTServer.Supervisor.remove_all_children sup_pid
    assert Process.whereis(:server) == nil
  end
end
