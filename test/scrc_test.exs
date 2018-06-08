defmodule ScrcTest do
  use ExUnit.Case
  doctest Scrc

  test "greets the world" do
    assert Scrc.hello() == :world
  end
end
