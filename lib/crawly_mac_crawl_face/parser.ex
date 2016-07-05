defmodule CrawlyMacCrawlFace.Parser do

  require Logger

  @domain "textmaster.com"

  def parse(_url, depth, body) do
    body
    |> Floki.find("a")
    |> Floki.attribute("href")
    |> Enum.filter(&same_domain?(URI.parse(&1).host, @domain))
    |> Enum.each(&CrawlyMacCrawlFace.Store.add(&1, depth + 1))
  end

  defp same_domain?(nil, nil), do: false
  defp same_domain?(_, nil), do: false
  defp same_domain?(nil, _), do: false
  defp same_domain?(x, y) do
    String.ends_with?(x, y)
  end
end
