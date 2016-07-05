defmodule CrawlyMacCrawlFace.Transport.AMQP.ChannelPool do

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_) do
    pool_options = [
      {:name, {:local, :amqp_channel_pool}},
      {:worker_module, CrawlyMacCrawlFace.Transport.AMQP.ChannelWorker},
      {:size, 1},
      {:max_overflow, 5}
    ]

    children = [
      :poolboy.child_spec(:amqp_channel_pool, pool_options, [])
    ]

    supervise children, strategy: :one_for_one
  end

  def publish(routing_key, payload) do
    :poolboy.transaction(:amqp_channel_pool, fn(pid) ->
      GenServer.cast(pid, {:publish, routing_key, payload})
    end)
  end
end
