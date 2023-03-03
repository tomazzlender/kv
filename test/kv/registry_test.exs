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

  test "removes bucket if bucket crashes", %{server: reg} do
    KV.Registry.create(reg, "shopping")
    assert {:ok, bucket } = KV.Registry.lookup(reg, "shopping")

    # let it crash ...
    Agent.stop(bucket)

    # ... and the bucket should no longer be returned on a
    # lookup
    assert KV.Registry.lookup(reg, "shopping") == :error
  end

end
