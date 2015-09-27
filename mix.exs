defmodule OrderedList.Mixfile do
  use Mix.Project

  def project do
    [app: :ordered_list,
     version: "0.1.0",
     elixir: "~> 1.0",
     deps: deps,
     source_url: "https://github.com/aarondufall/ordered_list",
     # Hex
     description: description,
     package: package,
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [{:inch_ex, only: :docs}]
  end

  defp description do
    """
    Sorting and reordering positions in a list.
    """
  end

  defp package do
    [contributors: ["Aaron Dufall"],
     licenses: ["MIT"],
     links: %{github: "https://github.com/aarondufall/ordered_list"},
     files: ~w(mix.exs README.md LICENSE lib)]
  end
end
