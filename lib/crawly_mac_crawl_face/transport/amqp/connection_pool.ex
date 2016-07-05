defmodule CrawlyMacCrawlFace.Transport.AMQP.ConnectionPool do

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_) do
    pool_options = [
      {:name, {:local, :amqp_connection_pool}},
      {:worker_module, CrawlyMacCrawlFace.Transport.AMQP.ConnectionWorker},
      {:size, 1},
      {:max_overflow, 5}
    ]

    children = [
      :poolboy.child_spec(:amqp_connection_pool, pool_options, %{
        host: "localhost",
        port: 5672,
        username: "immvnaiq",
        password: "immvnaiq",
        vhost: "immvnaiq"
      })
    ]

    supervise children, strategy: :one_for_one
  end

  def channel do
    :poolboy.transaction(:amqp_connection_pool, fn(pid) ->
      GenServer.call(pid, :channel)
    end)
  end
end
