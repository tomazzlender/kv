defmodule KV.Supervisor do
  use Supervisor

  require Logger

  def start_link(opts) do
    Logger.debug "KV.Supervisor start"
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {KV.Registry, name: KV.Registry}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

end
