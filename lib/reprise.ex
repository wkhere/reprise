defmodule Reprise do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Reprise.Server, [[interval: 1000]])
    ]

    opts = [strategy: :one_for_one, name: Reprise.Supervisor]
    Supervisor.start_link(children, opts)
  end
end


defmodule Reprise.Server do
  use GenServer

  def start_link(kw) do
    GenServer.start_link(__MODULE__, kw, name: Reprise)
  end

  def interval(arg\\nil), do: GenServer.call(Reprise, {:interval, arg})

  # callbacks

  def init(kw) do
    interval = kw[:interval]
    cond do
      !interval -> {:stop, "pass interval arg"}
      :ok ->
        wait(interval)
        {:ok, {now(), interval}}
    end
  end

  def handle_info(:wake, {last, interval}) do
    timestamp = now()
    Reprise.Runner.go(last, timestamp)
    wait(interval)
    {:noreply, {timestamp, interval}}
  end

  def handle_call({:interval, nil}, _from, st={_, interval}) do
    {:reply, interval, st}
  end

  def handle_call({:interval, new_interval}, _from, {last, interval}) do
    {:reply, {:ok, [prev: interval]}, {last, new_interval}}
  end

  # helpers

  defp wait(interval), do: Process.send_after(self, :wake, interval)
  defp now(), do: :erlang.localtime
end


defmodule Reprise.Runner do
  require Logger

  @moduledoc """
  Module discovery and reloading.

  The main entry point is `go/2` function.
  """

  @type time :: :calendar.datetime
  @type beam :: String.t

  @spec iterate_beams([String.t]) :: [beam]
  defp iterate_beams(load_paths) do
    for d <- load_paths do
      for f <- File.ls!(d), Path.extname(f)==".beam", do: Path.join(d,f)
    end |> List.flatten
  end

  @doc """
  Returns all beam files belonging to the current mix project.
  """
  @spec beams() :: [beam]
  def beams(), do: iterate_beams(Mix.Project.load_paths)

  @doc """
  Returns pairs of beam files and modules which are loaded
  and  belong to the current mix project.
  """
  @spec beam_modules() :: [{beam, module}]
  def beam_modules() do
    beamset = beams |> Enum.into HashSet.new
    for {m,f0} <- :code.all_loaded, is_list(f0),
      f = Path.expand(f0), Set.member?(beamset, f),
      do: {f,m}
  end

  @doc "Reloads a single module."
  @spec reload(module) :: {:module, module} | {:error, atom}
  def reload(module) do
    :code.purge(module)
    :code.load_file(module)
  end

  @doc """
  Attempts to reload all modules belonging to the current mix project,
  which changed between given time frames.
  If there were any and they reloaded successfully, prints a summary
  via `Logger.info/1`.

  Modules whose reload errored are silently ignored.

  Returns `:ok` if there were any modules successfully reloaded
  or `nil` when there were none.
  """
  @spec go(time, time) :: :ok | nil
  def go(from, to) do
    modules = for {f,m} <- beam_modules do
      case File.stat(f) do
        {:ok, %File.Stat{mtime: mtime}} when mtime >= from and mtime < to ->
          case reload(m) do
            {:module, m} -> {:reloaded, m}
            {:error, _} -> {:load_error, m}
          end
        {:ok, _} -> {:unmodified, m}
        {:error, _} -> {:fstat_error, m}
      end
    end
    reloaded = for {:reloaded, m} <- modules, do: m
    unless reloaded == [], do:
      Logger.info("Reloaded modules: #{inspect reloaded}")
  end
end
