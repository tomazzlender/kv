defmodule KV.Bucket do
  use Agent

  @doc """
  Starts a new bucket
  """
  def start_link(_opts) do
    Agent.start_link(fn -> %{} end)
  end

  @doc """
  Get value by key from bucket.
  """
  def get(bucket, key) do
    Agent.get(bucket, fn m -> Map.get(m, key) end)
  end

  @doc """
  Update key in bucket.
  """
  def put(bucket, key, value) do
    Agent.update(bucket, fn m -> Map.put(m, key, value) end)
  end

  @doc """
  Delete key from bucket.

  Returns value of key if key exists.
  """
  def delete(bucket, key) do
    Agent.get_and_update(bucket, fn m -> Map.pop(m, key) end)
  end

end
