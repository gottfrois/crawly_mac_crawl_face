defmodule CrawlyMacCrawlFace.Worker do

  require Logger
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(state) do
    :timer.send_after(0, :poll)
    {:ok, state}
  end

  def crawl(pid, url, depth) do
    GenServer.cast(pid, {:crawl, url, depth})
  end

  def handle_info(:poll, state) do
    case CrawlyMacCrawlFace.Store.take do
      {:ok, nil} ->
        :timer.send_after(2000, self, :poll)
      {:ok, url, depth} ->
        crawl(self, url, depth)
    end

    {:noreply, state}
  end

  def handle_info({_, {:error, :req_timedout}}, state) do
    {:noreply, state}
  end

  def handle_cast({:crawl, url, depth}, state) do
    case CrawlyMacCrawlFace.Crawler.fetch(url, depth) do
      {:ok, body} ->
        Logger.info "#{inspect self} [#{depth}] Crawled #{url}: #{String.length(body)}"
        CrawlyMacCrawlFace.Transport.AMQP.ChannelPool.publish("page.crawled", Poison.encode!(%{ url: url, depth: depth, body: body }))
      {:error, "retry_later"} ->
        Logger.info "#{inspect self} [#{depth}] Must retry #{url}"
        CrawlyMacCrawlFace.Store.add(url, depth)
      {:error, reason} ->
        Logger.info "#{inspect self} [#{depth}] Error fetching #{url}: #{reason}"
    end

    :timer.send_after(2000, self, :poll)

    {:noreply, state}
  end
end
