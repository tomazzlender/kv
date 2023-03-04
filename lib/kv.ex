defmodule KV do
  use Application

  require Logger

  @impl true
  def start(_type, _args) do
    Logger.info "App start ..."
    KV.Supervisor.start_link(name: KV.Supervisor)
  end
end
