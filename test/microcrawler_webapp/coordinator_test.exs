defmodule MicrocrawlerWebapp.CoordinatorTest do
  use ExUnit.Case, async: true

  alias MicrocrawlerWebapp.Coordinator

  import Coordinator, only: [requested: 2, commited: 2]

  @some_key "some key"
  @other_key "other key"

  @lower_ttl 100
  @some_ttl 314
  @higher_ttl 500

  setup do
    Coordinator.reset
  end

  test "more requests from one process is not allowed" do
    :accepted = requested(@some_key, @some_ttl)

    assert {:error, :already_requester} = requested(@some_key, @some_ttl)
    assert {:error, :already_requester} = requested(@other_key, @some_ttl)
  end

  test "commited key with the same and lower ttl is rejected" do
    :accepted = requested(@some_key, @higher_ttl)
    :ok = commited(@some_key, @higher_ttl)

    assert :rejected = requested(@some_key, @higher_ttl)
    assert :rejected = requested(@some_key, @lower_ttl)
  end

  test "commited key with higher ttl is accepted" do
    :accepted = requested(@some_key, @lower_ttl)
    :ok = commited(@some_key, @lower_ttl)

    assert :accepted = requested(@some_key, @higher_ttl)
  end

  test "is possible to commit more different keys" do
    :accepted = requested(@some_key, @some_ttl)
    :ok = commited(@some_key, @some_ttl)
    :accepted = requested(@other_key, @some_ttl)
    :ok = commited(@other_key, @some_ttl)

    assert :rejected = requested(@some_key, @some_ttl)
    assert :rejected = requested(@other_key, @some_ttl)
  end

  test "is possible to request key if previous requester dies" do
    test_pid = self
    requester = spawn(fn ->
      send test_pid, {self, requested(@some_key, @some_ttl)}
    end)

    assert_receive {^requester, :accepted}
    assert :accepted = requested(@some_key, @some_ttl)
  end

  test "waiting requester is rejected after commit from another" do
    :accepted = requested(@some_key, @some_ttl)
    test_pid = self
    anothers = Enum.map(1..10, fn(_) -> spawn(fn ->
      send test_pid, {self, requested(@some_key, @some_ttl)}
    end) end)
    # wait for a white to give anothers a chance to request uncommited key
    Process.sleep(50)
    :ok = commited(@some_key, @some_ttl)

    Enum.each(anothers, fn(another) ->
      assert_receive {^another, :rejected}
    end)
  end

  test "waiting requester is accepted after another dies" do
    test_pid = self
    another = spawn(fn ->
      send test_pid, {self, requested(@some_key, @some_ttl)}
      # give test process chance to request already requested key
      receive do :stop -> Process.sleep(50) end
    end)

    assert_receive {^another, :accepted}
    send another, :stop
    assert :accepted = requested(@some_key, @some_ttl)
  end

  test "is possible to commit already commited key" do
    :accepted = requested(@some_key, @some_ttl)
    :ok = commited(@some_key, @some_ttl)

    assert :rejected = requested(@some_key, @some_ttl)
    assert :ok = commited(@some_key, @lower_ttl)
    assert :accepted = requested(@some_key, @some_ttl)
    assert :ok = commited(@some_key, @higher_ttl)
    assert :rejected = requested(@some_key, @some_ttl)
  end

  test "is possible to commit without request" do
    assert :ok = commited(@some_key, @some_ttl)
    assert :rejected = requested(@some_key, @some_ttl)
  end

  test "waiting requester is rejected after 'wild' commit from another" do
    test_pid = self
    requested = spawn(fn ->
      send test_pid, {self, requested(@some_key, @some_ttl)}
      receive do :stop -> :ok end
    end)

    assert_receive {^requested, :accepted}

    waiting = spawn(fn ->
      send test_pid, {self, requested(@some_key, @some_ttl)}
    end)
    # give 'waiting' process chance to request key
    Process.sleep(50)
    # 'wild' commit from test process
    :ok = commited(@some_key, @some_ttl)

    assert_receive {^waiting, :rejected}

    send requested, :stop
    assert :rejected = requested(@some_key, @some_ttl)
  end
end
