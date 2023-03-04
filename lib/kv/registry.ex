defmodule KV.Registry do
  use GenServer

  require Logger

  @doc """
  Starts a registry
  """
  def start_link(opts) do
    Logger.debug "Registry start_link ..."
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Ensures that we have a named bucket on given server.
  """
  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  @doc """
  Looks up named bucket in server and returns it existing.
  """
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end


  @impl true
  def init(:ok) do
    Logger.debug "Registry init ..."
    refs = %{}
    names = %{}
    {:ok, {refs, names}}
  end

  @impl true
  def handle_call({:lookup, name}, _from, {_, names} = state) do
    Logger.debug "lookup: #{name}"
    {:reply, Map.fetch(names, name), state}
  end

  @impl true
  def handle_cast({:create, name}, {refs, names} = state) do
    Logger.debug "create: #{name}"
    if Map.has_key?(names, name) do
      {:noreply, state}
    else
      {:ok, bucket} = DynamicSupervisor.start_child(KV.BucketSupervisor, KV.Bucket)
      ref = Process.monitor(bucket)
      refs = Map.put(refs, ref, name)
      names = Map.put(names, name, bucket)
      {:noreply, {refs, names}}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _, _}, {refs, names}) do
    {name, refs} = Map.pop(refs, ref)
    Logger.debug "Bucket DOWN: #{name}"
    {_, names} = Map.pop(names, name)
    {:noreply, {refs, names}}
  end

  @impl true
  def handle_info(message, state) do
    Logger.info "received unknown message: #{inspect(message)}"
    {:noreply, state}
  end

end
