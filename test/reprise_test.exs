defmodule RepriseTest do
  use ExUnit.Case, async: false

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

  test "can find my modules via beam files" do
    for {_f,m} <- Reprise.Runner.beam_modules, do:
      assert "#{m}" =~ ~r/^Elixir\.Reprise/
  end

end
