defmodule TCPvP.Server.Start do
  @port Application.get_env(:tcpvp, :port)

  def start_server do
    {:ok, socket} = :gen_tcp.listen(@port, [{:active, :once}])
    spawn_acceptors(socket)
  end

  defp spawn_acceptors(socket) do
    {:ok, acceptor} = :gen_tcp.accept(socket)
    {:ok, acceptor_pid} = GenServer.start_link(__MODULE__, {:acceptor_loop, acceptor}, [])
    :gen_tcp.controlling_process(acceptor, acceptor_pid)
    spawn_acceptors(socket)
  end

  def init({:acceptor_loop, acceptor}) do
    {:ok, acceptor}
  end

  def handle_info({:tcp, _from, credentials}, state) do
    :inet.setopts(state, [{:active, :once}])
    IO.inspect credentials
    {:noreply, state}
  end
  def handle_info({:tcp_closed, socket}) do
    IO.inspect "Player has left"
    {:noreply, socket}
  end
end
