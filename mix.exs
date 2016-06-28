defmodule CrawlyMacCrawlFace.Mixfile do
  use Mix.Project

  def project do
    [app: :crawly_mac_crawl_face,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :httpotion],
     mod: {CrawlyMacCrawlFace, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:poolboy, "~> 1.5.1"},
      {:httpotion, github: "myfreeweb/httpotion", branch: "master"},
      {:floki, "~> 0.8"},
      {:amqp, "~> 0.1.4"},
      {:connection, "~> 1.0.2"},
      {:uuid, "~> 1.1"},
      {:timex, "~> 2.1.4"}
    ]
  end
end
