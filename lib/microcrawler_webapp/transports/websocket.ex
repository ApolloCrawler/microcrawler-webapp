defmodule MicrocrawlerWebapp.Transports.WebSocket do

  alias Phoenix.Endpoint.CowboyWebSocket
  alias Phoenix.Socket
  alias Phoenix.Transports.WebSocket

  @behaviour Phoenix.Socket.Transport

  defdelegate ws_init(args), to: WebSocket
  defdelegate ws_handle(opcode, payload, state), to: WebSocket
  defdelegate ws_info(msg, state), to: WebSocket
  defdelegate ws_terminate(reason, state), to: WebSocket
  defdelegate ws_close(state), to: WebSocket

  def default_config() do
    WebSocket.default_config() ++ [cowboy: CowboyWebSocket]
  end

  def init(conn, args) do
    case WebSocket.init(conn, args) do
      {:ok, conn, {module, {socket, opts}}} ->
        {:ok, conn, {module, {Socket.assign(socket, :conn, conn), opts}}}
      error ->
        error
    end
  end
end
