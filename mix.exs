defmodule Scrc.MixProject do
  use Mix.Project

  @version Path.join(__DIR__, "VERSION")
           |> File.read!()
           |> String.trim()

  def project do
    [
      app: :scrc,
      version: @version,
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),

      # Docs
      name: "SCRC",
      source_url: "https://github.com/krodelin/scrc-elixir",
      homepage_url: "https://github.com/krodelin/scrc-elixir",
      docs: [
        main: "readme", # The main page in the docs
        # logo: "path/to/logo.png",
        extras: ["README.md"]
      ]
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
      {:socket, "~> 0.3"},

      {:credo, "~> 0.9.1", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end

  defp description() do
    "Elixir implementation of SCRC Client and Server"
  end

  defp package() do
    [
      name: "scrc",
      maintainers: ["Udo Schneider"],
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub" => "https://github.com/krodelin/scrc-elixir"
      },
      files: package_files(),
    ]

    defp package_files() do
      ["VERSION"]
    end
  end
end
