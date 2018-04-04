defmodule Presto.Mixfile do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/ijcd/presto"
  @description "Single Page Apps in Elixir, without the Single Page App!"

  def project do
    [
      app: :presto,
      version: @version,
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env),
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps(),

      # docs
      description: @description,
      name: "Presto",
      source_url: @source_url,
      package: package(),
      dialyzer: [flags: "--fullpath"],
      docs: [
        main: "readme",
        source_ref: "v#{@version}",
        source_url: @source_url,
        extras: [
          "README.md"
        ]
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Presto.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:phoenix_html, "~> 2.10"},
      # {:phoenix, "~> 1.3.0", only: [:dev, :test], runtime: false},

      # docs
      {:ex_doc, "~> 0.16.4", only: :dev, runtime: false},
      {:earmark, "~> 1.2", only: :dev, runtime: false},

      {:mix_test_watch, "~> 0.3", only: [:dev, :test], runtime: false},
      {:credo, "~> 0.8.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev, :test], runtime: false},
      {:stream_data, "~> 0.2.0", only: [:dev, :test], runtime: false},
      {:mex, "~> 0.0.5", only: [:dev, :test], runtime: false},
    ]
  end

  defp package do
    [
      description: @description,
      files: ["lib", "config", "mix.exs", "README*"],
      maintainers: ["Ian Duggan"],
      licenses: ["Apache 2.0"],
      links: %{GitHub: @source_url}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      test: ["test --no-start"]
    ]
  end
end
