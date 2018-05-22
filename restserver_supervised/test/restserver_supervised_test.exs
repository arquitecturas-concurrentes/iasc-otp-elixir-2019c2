defmodule ServerTestTest do
  use ExUnit.Case

  test "start supervised worker" do
    {:ok, sup_pid} = RESTServer.Supervisor.start_link :server

    {:ok, worker_pid} = Supervisor.start_child(sup_pid, [])

    assert RESTServer.get(:server, "/document") == {:ok, :not_found}

    assert RESTServer.post(:server, "/document", "aaa") == :ok

    assert RESTServer.get(:server, "/document") == {:ok, "aaa"}
  end

  test "broke supervised worker" do
    {:ok, sup_pid} = RESTServer.Supervisor.start_link :server

    {:ok, worker_pid} = Supervisor.start_child(sup_pid, [])

    # Finish the server in an abnormal way
    GenServer.stop(:server, :kill)
    :timer.sleep(500)
    assert Process.alive?(Process.whereis(:server))


    # Finish the server in a normal way
    GenServer.stop(:server, :normal)
    :timer.sleep(500)
    assert Process.whereis(:server) == nil
  end
end
