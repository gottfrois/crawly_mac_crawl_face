defmodule CrawlyMacCrawlFace do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(CrawlyMacCrawlFace.Store, []),
      worker(CrawlyMacCrawlFace.WorkerPool, []),
      worker(CrawlyMacCrawlFace.Transport.AMQP.ConnectionPool, []),
      worker(CrawlyMacCrawlFace.Transport.AMQP.ChannelPool, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CrawlyMacCrawlFace.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
