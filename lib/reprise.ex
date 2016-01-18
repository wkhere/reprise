defmodule Reprise do
  use Application

  @moduledoc """
  Aplication supervising the `Reprise.Server`.
  """

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Reprise.Server, [[interval: 1000]])
    ]

    opts = [strategy: :one_for_one, name: Reprise.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
