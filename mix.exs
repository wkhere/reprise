defmodule Reprise.Mixfile do
  use Mix.Project

  def project do
    [app: :reprise,
     version: "0.2.3",
     elixir: "~> 0.15.0",
     description: description,
     package: package,
     deps: deps]
  end

  def application do
    [mod: {Reprise, []},
      applications: [],
      description: 'Simple module reloader',
     ]
  end

  defp deps do
    []
  end

  defp description do
    """
    Reprise reloads your modules after they've been recompiled.

    This is an intentionally simplified reloader when compared
    to the other ones, like exreloader or Mochiweb reloader.
    It aims to do one thing well.
    Only the beam files which were created under your mix project
    are scanned for changes. Deps are also excluded from checking
    and reloading. It doesn't try to compile changed sources --
    this task is better left to some shell tools like inotify.
    """
  end

  defp package do
    [ contributors: ["Wojciech Kaczmarek"],
      licenses: ["BSD"],
      description: description,
      links: %{"GitHub" => "https://github.com/herenowcoder/reprise"}
    ]
  end
end
