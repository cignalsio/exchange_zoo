defmodule ExchangeZoo.MixProject do
  use Mix.Project

  def project do
    [
      app: :exchange_zoo,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ExchangeZoo.Application, []}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib", "release"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:finch, "~> 0.22"},
      {:wind, github: "bfolkens/wind", ref: "8378c8b47cf8934b3fcb1b09bdb760a2eaadda85"},
      # {:wind, path: "/Users/bfolkens/dev/bfolkens-github/wind"},
      {:jason, "~> 1.1"},
      {:ecto, "~> 3.14"},
    ]
  end
end
