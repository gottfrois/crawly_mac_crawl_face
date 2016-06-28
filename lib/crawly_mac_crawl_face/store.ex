defmodule CrawlyMacCrawlFace.Store do

  require Logger

  @depth 100

  def start_link do
    Agent.start_link(fn -> Map.new end, name: __MODULE__)
  end

  def add(url, depth \\ 0) do
    Agent.update(__MODULE__, &Map.put_new(&1, strip_extra_slashes(url), %{depth: depth, crawled: false}), :infinity)
  end

  def take do
    Agent.get_and_update(__MODULE__, fn dict ->

      result = dict
        |> Enum.into([])
        |> Enum.find(fn(x) ->
          case x do
            {_key, %{depth: depth, crawled: false}} when depth <= @depth ->
              true
            _ ->
              false
          end
        end)

      case result do
        nil ->
          {{:ok, nil}, dict}
        {url, _} ->
          new_dict = dict
            |> Map.update!(url, fn(item) ->
              %{item | crawled: true}
            end)
          %{depth: depth} = Map.get(new_dict, url)
          {{:ok, url, depth}, new_dict}
      end
    end, :infinity)
  end

  defp strip_extra_slashes(url) do
    Regex.replace(~r/([^:]\/)\/+/, url, "\\1")
  end

end

# CrawlyMacCrawlFace.Store.add("http://www.textmaster.com/")
