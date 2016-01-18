defmodule RepriseTest do
  use ExUnit.Case, async: true

  setup do:
    Application.ensure_all_started :reprise

  doctest Reprise.Server

  test "can find my own beam files" do
    for b <- Reprise.Runner.beams, do:
      assert File.regular? b
  end

  test "my own beams have proper names" do
    for b <- Reprise.Runner.beams,
      not Regex.match?(~r[/consolidated/], b),
      f = b |> Path.split |> List.last,
      do:
        assert f =~ ~r/^Elixir\.Reprise\./ or f =~ ~r/^Elixir.Mix.Tasks\./
  end

  test "can find my own modules" do
    mods = for {f,m} <- Reprise.Runner.beam_modules,
      not Regex.match?(~r[/consolidated/], f),
      do: m
    refute mods == []
    for m <- mods, do:
      assert "#{m}" =~ ~r/^Elixir\.Reprise\b/
  end

end
