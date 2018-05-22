# Notes

## Supervision strategies

### one_for_one

If a child process terminates, only that process is restarted.

![Img](./images/sup4.gif)

### one_for_all

If a child process terminates, all other child processes are terminated, and then all child processes, including the terminated one, are restarted.

![Img](./images/sup5.gif)

### rest_for_one

If a child process terminates, the rest of the child processes (that is, the child processes after the terminated process in start order) are terminated. Then the terminated child process and the rest of the child processes are restarted.


### Simple_one_for_one
A `:simple_one_for_one` strategy is an enhancement of the standard `:one_for_one strategy` (which restarts a single replacement for every failed process), only it uses a single child spec for each of its new processes. This effectively makes each new worker an instance of the same process [(there’s more on the strategy in the Erlang documentation)](http://erlang.org/doc/design_principles/sup_princ.html#simple).

## Deprecation of Supervisor.Spec

A child spec specifies where the Supervisor should look to figure out how to start the supervised process. 

There is documentation currently out there on the web that encourages you to use the supervisor and worker helper functions from Supervisor.Spec to define child specs. Be aware that these helper methods are deprecated in Elixir 1.5 and beyond, and the correct way to implement this is to follow the “start_link/2, init/2 and strategies” section in the Supervisor spec [documentation](https://hexdocs.pm/elixir/Supervisor.html#module-start_link-2-init-2-and-strategies).

In this example the `RESTServer.Supervisor` is the responsible of the initialization of out `RESTServer` now. When we want to initialize a supervised RESTServer we should get first a supervisor and then a server pid from the supervisor.

```elixir
    {:ok, sup_pid} = RESTServer.Supervisor.start_link :server

    {:ok, server_pid} =Supervisor.start_child(sup_pid, [])
```

Now the pid referenced by _server_pid_ contains the pid which is a supervised RESTServer.

```elixir
  RESTServer.Supervisor.children(sup_id)
```

will call actually to

```elixir
Supervisor.which_children(sup_id)
```

which will get the list of tuples of type
`{id, child, type, modules}` tuples, where:

* id - as defined in the child specification
* child - the PID of the corresponding child process, `:restarting` if the process is about to be restarted, or `:undefined` if there is no such process
* type - `:worker` or `:supervisor`, as specified by the child specification
* modules - as specified by the child specification

## Elixir +1.5 quirks

One unique behavior about using Elixir 1.5’s module-based Supervisor scheme is that all calls to the child start_link will have the Supervisor’s init argument concatenated to the arguments you pass to your child- This effectively means that if your Supervisor is supposed to pass `{:name}` to the child’s start_link, you should actually expect it to pass two arguments, `[], {:name}` to the function.

Now we should also change this on the `RESTServer` functions:

```elixir
  def start_link([], name) do
    start_link(name)
  end

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, [name: name])
  end
```

## Dynamic Supervision

See the [Changelog of Elixir 1.6](https://github.com/elixir-lang/elixir/blob/v1.6/CHANGELOG.md#dynamic-supervisor) about the quirks and changes of dynamic supervision.

Supervisors in Elixir are responsible for starting, shutting down and restarting child process when things go wrong. Most of the interaction with supervisors happen with the Supervisor module and it contains three main strategies: :one_for_one, `:rest_for_one` and `:one_for_all`.

However, sometimes the children of a supervisor are not known upfront and are rather started dynamically. For example, if you are building a web server, you have each request beind handled by a separate supervised process. Those cases were handled in the Supervisor module under a special strategy called `:simple_one_for_one`.

Unfortunately, this special strategy changed the semantics of the supervisor in regards to initialization and shutdown. Plus some APIs expected different inputs or would be completely unavailable depending on the supervision strategy.

Elixir v1.6 addresses this issue by introducing a new DynamicSupervisor module, which encapsulates the old `:simple_one_for_one` strategy and APIs in a proper module while allowing the documentation and API of the Supervisor module to focus on its main use cases. Having a separate DynamicSupervisor module also makes it simpler to add new features to the dynamic supervisor, such as the new `:max_children` option that limits the maximum number of children supervised dynamically.

We now have the new `RESTServer.Supervisor` as a *DynamicSupervisor* and follow a few minor changes:

* We do not pass in a spec into start_link, and we revert our strategy to :one_for_one.
* Note that DynamicSupervisor.start_child now passes a child spec as the second argument.

```elixir
def start_link do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_restserver(sup, name \\ :bleh) do
    spec = {RESTServer, name}
    DynamicSupervisor.start_child(sup, spec)
  end

  ...

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
```