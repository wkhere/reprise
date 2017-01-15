defmodule Reprise.Server do
  use GenServer
  alias Reprise.Runner

  @moduledoc """
  Server scanning project beam files for changes and reloading them.

  The server is just repeatedly firing messages in a given time interval
  and then delegating the actual work to `Reprise.Runner`.
  """

  @doc """
  Starts the server passing a keyword list of arguments.

  Currently valid and required arguments are:
  `[interval: millis]`
  """
  @spec start_link(Keyword.t) :: any

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: Reprise)
  end


  @doc """
  Reads or sets the current interval
  between scans for module changes.

  When called without argument, returns the current interval.

  When called with argument, sets the interval (in milliseconds)
  and returns previous one.

  ## Examples

      iex> Reprise.Server.interval
      1000
      iex> Reprise.Server.interval(2000)
      {:ok, [prev: 1000]}
  """
  @spec interval() :: non_neg_integer
  @spec interval(integer | nil) :: non_neg_integer | {:ok, Keyword.t}

  def interval(millis \\ nil), do:
    GenServer.call(Reprise, {:interval, millis})


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
    Runner.go(last, timestamp)
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

  @spec wait(non_neg_integer) :: reference
  defp wait(interval), do: Process.send_after(self(), :wake, interval)

  @spec now() :: Runner.time
  defp now(), do: :erlang.localtime
end
