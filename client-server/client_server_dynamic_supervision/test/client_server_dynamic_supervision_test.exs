defmodule ClientServerDynamicSupervisionTest do
  use ExUnit.Case
  doctest ClientServerDynamicSupervision

  test "greets the world" do
    assert ClientServerDynamicSupervision.hello() == :world
  end
end
