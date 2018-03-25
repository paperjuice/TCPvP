defmodule TcpvpTest do
  use ExUnit.Case
  doctest Tcpvp

  test "greets the world" do
    assert Tcpvp.hello() == :world
  end
end
