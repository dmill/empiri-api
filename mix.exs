defmodule EmpiriApi.Mixfile do
  use Mix.Project

  def project do
    [app: :empiri_api,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases,
     deps: deps]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {EmpiriApi, []},
     applications: [:phoenix, :phoenix_html, :cowboy,
                    :logger, :phoenix_ecto, :postgrex,
                    :ex_aws, :httpoison]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.1.1"},
     {:phoenix_ecto, "~> 2.0"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_html, "~> 2.3"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:cowboy, "~> 1.0"},
     {:joken, "~> 0.16"},
     {:corsica, "~> 0.4"},
     {:faker, "~> 0.6"},
     {:httpoison, "~> 0.7"},
     {:ex_aws, "~> 0.4.10"},
     {:arc, "~> 0.2.0", git: "https://github.com/dmill/arc.git", override: true},
     {:arc_ecto, "~> 0.3.1"},
     {:mock, "~> 0.1.1", only: :test}]
  end

  # Aliases are shortcut or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"]]
  end
end
