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

  def start_link(kw), do: GenServer.start_link(__MODULE__, kw)

  # callbacks

  def init(kw) do
    interval = kw[:interval]
    cond do
      !interval -> {:stop, "pass interval arg"}
      :ok ->
        wait(interval)
        {:ok, {stamp, interval}}
    end
  end

  def handle_info(:wake, {last, interval}) do
    now = stamp
    Reprise.Runner.go(last, now)
    wait(interval)
    {:noreply, {now, interval}}
  end

  # helpers

  defp wait(interval), do: Process.send_after(self, :wake, interval)
  defp stamp(), do: :erlang.localtime
end


defmodule Reprise.Runner do
  def beams() do
    for d <- Mix.Project.load_paths do
      for f <- File.ls!(d), Path.extname(f)==".beam", do: Path.join(d,f)
    end |> List.flatten
  end

  def beam_modules() do
    beamset = beams |> Enum.into HashSet.new
    for {m,f0} <- :code.all_loaded, is_list(f0),
      f = Path.expand(f0), Set.member?(beamset, f),
      do: {f,m}
  end

  def reload(module) do
    :code.purge(module)
    :code.load_file(module)
  end

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
      :error_logger.info_msg("Reloaded modules: #{inspect reloaded}\n")
  end
end
