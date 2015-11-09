defmodule RepriseTest do
  use ExUnit.Case, async: true

  setup do:
    Application.ensure_all_started :reprise

  doctest Reprise.Server

  def _reprise_on_reload do
    case :erlang.get(:hook_test) do
      :undefined -> :erlang.put(:hook_test, 1)
      n -> :erlang.put(:hook_test, n+1)
    end
  end

  test "my own beams have proper names" do
    for b <- Reprise.Runner.beams,
      f = b |> Path.split |> List.last,
      do:
        assert f =~ ~r/^Elixir\.Reprise\./
  end

  test "can find my own beam files" do
    for b <- Reprise.Runner.beams, do:
      assert File.regular? b
  end

  test "can find my own modules" do
    mods = for {_f,m} <- Reprise.Runner.beam_modules, do: m
    refute mods == []
    for m <- mods, do:
      assert "#{m}" =~ ~r/^Elixir\.Reprise\b/
  end

  test "can call reload hook" do 
    Reprise.Runner.call_reload_hook(RepriseTest)
    Reprise.Runner.call_reload_hook(RepriseTest)
    assert :erlang.get(:hook_test) == 2
  end

end
