defmodule CrawlyMacCrawlFace.Transport.AMQP.ChannelWorker do

  use GenServer
  use Timex
  require Logger

  @exchange "textmaster"

  def start_link(_) do
    {:ok, channel} = CrawlyMacCrawlFace.Transport.AMQP.ConnectionPool.channel
    GenServer.start_link(__MODULE__, channel)
  end

  def init(channel) do
    {:ok, channel}
  end

  def handle_cast({:publish, routing_key, payload}, channel) do
    AMQP.Basic.publish(channel, @exchange, routing_key, payload)
    {:noreply, channel}
  end

  def terminate(channel) do
    Logger.info "-------------"
    AMQP.Channel.close(channel)
    {:ok, nil}
  end
end

# persistent: true,
# content_type: "text/html",
# message_id: UUID.uuid4,
# timestamp: Time.now |> Tuple.to_list |> Enum.join
