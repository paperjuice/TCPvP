defmodule TCPvP.Client.Login do
  require Logger
  @host Application.get_env(:tcpvp, :host)
  @port Application.get_env(:tcpvp, :port)

  def connect_to_server do
    case :gen_tcp.connect(@host, @port, [{:active, :once}]) do
      {:ok, socket} ->
        Logger.info("Connected")
        store_connection(socket)
        register_name()
      {:error, reason} ->
        Logger.error("Could not connect to server. Reason: #{reason}")
    end
  end

  defp store_connection(socket) do
    GenServer.start_link(__MODULE__, {:connection, socket}, [{:name, :connection}])
  end
  def init({:connection, socket}) do
    {:ok, socket}
  end
  defp get_connection do
    GenServer.call(:connection, :get)
  end

  def handle_call(:get, _from, socket) do
    {:reply, socket, socket}
  end

  def register_name do
    tribe_name = IO.gets("What is your tribe's name?\n")
    tribe_password = IO.gets("What is your password?\n")
    tribe_credentials = "#{tribe_name},#{tribe_password}"
    send_name_to_server(tribe_credentials)
  end

  defp send_name_to_server(tribe_credentials) do
    socket = get_connection()
    :gen_tcp.send(socket, tribe_credentials)
  end
end
