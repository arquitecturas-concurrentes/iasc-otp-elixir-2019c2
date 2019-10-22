# RestserverSupervised

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add restserver_supervised to your list of dependencies in `mix.exs`:

        def deps do
          [{:restserver_supervised, "~> 0.0.1"}]
        end

  2. Ensure restserver_supervised is started before your application:

        def application do
          [applications: [:restserver_supervised]]
        end

## How to use it 

```elixir
{:ok, sup_pid} = RESTServer.Supervisor.start_link :server
```

RESTServer.get(:server, "/document")
RESTServer.post(:server, "/document", "aaa")
RESTServer.get(:server, "/document")

Process.whereis(:server)

Process.alive?(Process.whereis(:server))

GenServer.stop(:server, :kill)