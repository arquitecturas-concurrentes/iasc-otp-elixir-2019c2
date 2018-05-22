defmodule ClientServerSupervisedTest do
  use ExUnit.Case
  doctest ClientServerSupervised

  test "greets the world" do
    assert ClientServerSupervised.hello() == :world
  end
end
