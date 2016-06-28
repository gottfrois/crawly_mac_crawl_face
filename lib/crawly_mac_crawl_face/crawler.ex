defmodule CrawlyMacCrawlFace.Crawler do

  @timeout 10000

  def fetch(url, depth) do
    handle_response(
      url,
      depth,
      HTTPotion.get(url, [
        follow_redirects: true,
        timeout: @timeout
      ])
    )
  end

  defp handle_response(url, depth, %HTTPotion.Response{status_code: code, body: body}) when code in 200..299 do
    CrawlyMacCrawlFace.Parser.parse(url, depth, body)
    {:ok, body}
  end

  defp handle_response(_, _, %HTTPotion.Response{status_code: 400}) do
    {:error, :bad_request}
  end

  defp handle_response(_, _, %HTTPotion.Response{status_code: 401}) do
    {:error, :unauthorized}
  end

  defp handle_response(_, _, %HTTPotion.Response{status_code: 403}) do
    {:error, :forbidden}
  end

  defp handle_response(_, _, %HTTPotion.Response{status_code: 404}) do
    {:error, :not_found}
  end

  defp handle_response(_, _, %HTTPotion.ErrorResponse{message: message}) do
    {:error, message}
  end

end
