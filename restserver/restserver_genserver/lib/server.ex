defmodule Server do

  # ------- Client API

  def start_link do
    pid = spawn_link __MODULE__, :loop, [%{}]
    {:ok, pid}
  end

  def get(server, url) do
    ref = make_ref
    send server, {self, ref, {:get, url}}
    receive do
      {^ref, response} -> {:ok, response}
    after
      3_000 -> {:error, :timeout}
    end
  end

  def post(server, url, body) do
    send server, {self, {:post, url, body}}
  end

  def put(server, url, body) do
    send server, {self, {:put, url, body}}
  end

  def delete(server, url) do
    send server, {self, {:delete, url}}
  end

  # ------- Server

  def loop(state) do
    receive do
      {from, ref, {:get, url}} ->
        if Map.has_key?(state, url) do
          send from, {ref, Map.get(state, url)}
        else
          send from, {ref, :not_found}
        end
        loop(state)

      {_from, {:post, url, body}} ->  
        loop(Map.put(state, url, body))

      {_from, {:put, url, body}} ->  
        loop(Map.put(state, url, body))

      {_from, {:delete, url}} ->  
        loop(Map.delete(state, url))

      _ ->
        IO.puts "Message not understood :("
    end
  end
end