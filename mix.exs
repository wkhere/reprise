defmodule Reprise.Mixfile do
  use Mix.Project

  def project do
    [app: :reprise,
     version: "0.1.0",
     elixir: "~> 0.14.2",
     deps: deps]
  end

  def application do
    [applications: [],
     mod: {Reprise, []}]
  end

  defp deps do
    []
  end
end
