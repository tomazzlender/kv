defmodule KV.Registry do
  use GenServer

  @doc """
  Starts a registry
  """
  def start_link(opts) do
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
    refs = %{}
    names = %{}
    {:ok, {refs, names}}
  end

  @impl true
  def handle_call({:lookup, name}, _from, {_, names} = state) do
    {:reply, Map.fetch(names, name), state}
  end

  @impl true
  def handle_cast({:create, name}, {refs, names} = state) do
    if Map.has_key?(names, name) do
      {:noreply, state}
    else
      {:ok, bucket} = KV.Bucket.start_link([])
      ref = Process.monitor(bucket)
      refs = Map.put(refs, ref, name)
      names = Map.put(names, name, bucket)
      {:noreply, {refs, names}}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _, _}, {refs, names}) do
    {name, refs} = Map.pop(refs, ref)
    {_, names} = Map.pop(names, name)
    {:noreply, {refs, names}}
  end

  @impl true
  def handle_info(message, state) do
    require Logger
    Logger.info "received unknown message: #{inspect(message)}"
    {:noreply, state}
  end

end
