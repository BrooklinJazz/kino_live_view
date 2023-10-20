defmodule KinoLiveView.MixProject do
  use Mix.Project
  @source_url "https://github.com/brooklinjazz/kino_live_view"

  def project do
    [
      app: :kino_live_view,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:kino, "~> 0.10.0"},
      {:phoenix, "~> 1.7.7"},
      {:ex_doc, "~> 0.30.9"},
    ]
  end

  defp package do
    %{
      maintainers: ["Brooklin Myers"],
      description: "Dynamically Inject LiveViews into a Phoenix application from within Livebook",
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      },
      source_url: @source_url
    }
  end
end
