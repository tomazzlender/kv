defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, reg} = KV.Registry.start_link([])
    %{server: reg}
  end

  test "lookup returns existing bucket", %{server: reg} do
    assert KV.Registry.lookup(reg, "shopping") == :error

    KV.Registry.create(reg, "shopping")
    assert {:ok, bucket } = KV.Registry.lookup(reg, "shopping")

    KV.Bucket.put(bucket, "milk", 3)
    assert KV.Bucket.get(bucket, "milk") == 3
  end

end
