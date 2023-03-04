defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  setup do
    reg = start_link_supervised!(KV.Registry)
    %{server: reg}
  end

  test "lookup returns existing bucket", %{server: reg} do
    assert KV.Registry.lookup(reg, "shopping") == :error

    KV.Registry.create(reg, "shopping")
    assert {:ok, bucket } = KV.Registry.lookup(reg, "shopping")

    KV.Bucket.put(bucket, "milk", 3)
    assert KV.Bucket.get(bucket, "milk") == 3
  end

  test "removes bucket if bucket stops", %{server: reg} do
    KV.Registry.create(reg, "shopping")
    assert {:ok, bucket } = KV.Registry.lookup(reg, "shopping")

    # Stop the agent ...
    Agent.stop(bucket)

    # ... and the bucket should no longer be returned on a
    # lookup
    assert KV.Registry.lookup(reg, "shopping") == :error
  end

  test "removes bucket if bucket crashes", %{server: reg} do
    KV.Registry.create(reg, "shopping")
    assert {:ok, bucket } = KV.Registry.lookup(reg, "shopping")

    # Crash the agent ...
    Agent.stop(bucket, :shutdown)

    # ... and the bucket should no longer be returned on a
    # lookup
    assert KV.Registry.lookup(reg, "shopping") == :error
  end

  test "crashes of a bucket do not clear the registry", %{server: reg} do
    KV.Registry.create(reg, "shopping")
    KV.Registry.create(reg, "office")
    assert {:ok, bucket } = KV.Registry.lookup(reg, "shopping")

    # Crash the agent ...
    Agent.stop(bucket, :shutdown)

    # ... the office bucket should be still in the registry.
    assert {:ok, _ } = KV.Registry.lookup(reg, "office")
  end

end
