defmodule CrawlyMacCrawlFace.WorkerPool do

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_) do
    pool_options = [
      {:name, {:local, :worker_pool}},
      {:worker_module, CrawlyMacCrawlFace.Worker},
      {:size, 1000},
      {:max_overflow, 1000}
    ]

    children = [
      :poolboy.child_spec(:worker_pool, pool_options, [])
    ]

    supervise children, strategy: :one_for_one
  end

end
