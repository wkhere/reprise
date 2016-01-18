defmodule RepriseTest do
  use ExUnit.Case, async: true
  alias Reprise.Runner

  setup do:
    Application.ensure_all_started :reprise

  doctest Reprise.Server

  test "can find my own beam files" do
    for b <- Runner.beams, do:
      assert File.regular? b
  end

  test "my own beams have proper names" do
    for b <- Runner.beams,
      not Regex.match?(~r[/consolidated/], b),
      f = b |> Path.split |> List.last,
      do:
        assert f =~ ~r/^Elixir\.Reprise\./ or f =~ ~r/^Elixir.Mix.Tasks\./
  end

  test "can find my own modules" do
    mods = for {f,m} <- Runner.beam_modules,
      not Regex.match?(~r[/consolidated/], f),
      do: m
    refute mods == []
    for m <- mods, do:
      assert "#{m}" =~ ~r/^Elixir\.Reprise\b/
  end

end
