defmodule CrawlyMacCrawlFace.Transport.AMQP.ConnectionWorker do

  use Connection

  def start_link(opts) do
    Connection.start_link(__MODULE__, opts)
  end

  def init(opts) do
    state = %{opts: opts, conn: nil}
    {:connect, nil, state}
  end

  def disconnect(_info, state) do
    {:connect, :reconnect, %{state | conn: nil}}
  end

  def connect(_info, %{conn: nil, opts: %{host: host, port: port, username: username, password: password, vhost: vhost}} = state) do
    handle_connection(state, AMQP.Connection.open(
      host: host,
      port: port,
      username: username,
      password: password,
      virtual_host: vhost,
      connection_timeout: 5000,
      heartbeat: 60
    ))
  end

  defp handle_connection(state, {:ok, %AMQP.Connection{pid: pid} = conn}) do
    Process.link(pid)
    {:ok, %{state | conn: conn}}
  end

  defp handle_connection(state, {:error, _}) do
    {:backoff, 1000, state}
  end

  ### GenServer Implementation

  def handle_call(:channel, _from, %{conn: conn} = state) do
    {:ok, channel} = AMQP.Channel.open(conn)
    {:reply, {:ok, channel}, state}
  end

  def handle_call(_, _, %{conn: nil} = state) do
    {:reply, {:error, :closed}, state}
  end

  def handle_call(:close, from, state) do
    {:disconnect, {:close, from}, state}
  end
end
