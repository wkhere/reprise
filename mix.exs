defmodule Reprise.Mixfile do
  use Mix.Project

  def project do
    [app: :reprise,
     version: "0.5.2-dev",
     elixir: "~> 1.1",
     description: description(),
     package: package(),
     deps: deps()]
  end

  def application do
    [mod: {Reprise, []},
      registered: [Reprise],
      applications: [:logger],
      description: 'Simple module reloader',
     ]
  end

  defp deps do 
    [
      {:dialyze,   "~> 0.2",    only: :dev},
      {:ex_doc,    "~> 0.30.6",   only: :dev},
    ]
  end

  defp description do
    """
    Reprise reloads your modules after they've been recompiled.

    It is thought as a companion to inotify tools.
    It scans for changes in beam files belonging to youyr project.
    Doesn't recompile stuff by itself.
    """
  end

  defp package do
    [ maintainers: ["Wojciech Kaczmarek",
      "Yurii Rashkovskii", "Jay Doane", "Josh Austin"],
      licenses: ["BSD"],
      description: description(),
      links: %{"GitHub" => "https://github.com/herenowcoder/reprise"}
    ]
  end
end
