defmodule TCPvP.Server do
  @port 9999

  def start_server do
    {:ok, socket} = :gen_tcp.listen(@port, [{:active, :once}])
    GenServer.start_link(__MODULE__, {:manage_acceptor, []}, [{:name, :manage_acceptor}])
    spawn_acceptor(socket)
  end

  defp spawn_acceptor(socket) do
    {:ok, acceptor} = :gen_tcp.accept(socket)
    add_acceptor(acceptor)
    {:ok, acceptor_pid} = GenServer.start_link(__MODULE__, {:acceptor, acceptor})
    :gen_tcp.controlling_process(acceptor, acceptor_pid)

    spawn_acceptor(socket)
  end

  def init({:acceptor, acceptor}) do
    {:ok, acceptor}
  end

  def init({:manage_acceptor, []}) do
    {:ok, []}
  end

  def add_acceptor(acceptor) do
    GenServer.cast(:manage_acceptor, {:add, acceptor})
  end

  def broadcast_message_to_acceptors(message, pid) do
    GenServer.cast(:manage_acceptor, {:broadcast, message, pid})
  end

  def handle_cast({:add, acceptor}, state) do
    {:noreply, [acceptor|state]}
  end

  def handle_cast({:broadcast, message, pid}, state) do
    state
    |> Enum.filter(fn elem -> elem != pid end)
    |> Enum.each(fn socket -> :gen_tcp.send(socket, message) end)

    {:noreply, state}
  end

  def handle_info({:tcp, _, message}, state) do
    :inet.setopts(state, [{:active, :once}])
    IO.inspect message
    broadcast_message_to_acceptors(message, state)
    {:noreply, state}
  end
  def handle_info({:tcp_closed, socket}, state) do
    IO.inspect socket
    IO.inspect "is closed"
    {:noreply, state}
  end
end

