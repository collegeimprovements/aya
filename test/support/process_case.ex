defmodule Aya.ProcessCase do
  @moduledoc """
  Test case for GenServer, Agent, and other OTP process tests.

  Provides helpers for process lifecycle management and synchronization.
  Never uses `Process.sleep` — always uses monitors and `:sys` for sync.

  ## Usage

      use Aya.ProcessCase, async: true

      test "process starts and handles messages" do
        {:ok, pid} = start_supervised!({MyWorker, arg: "value"})

        sync(pid)  # ensure process has handled all prior messages
        assert_alive(pid)

        stop_and_await(pid)
      end
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import Aya.ProcessCase
    end
  end

  setup tags do
    Aya.DataCase.setup_sandbox(tags)
    :ok
  end

  @doc """
  Synchronize with a process — ensures all prior messages have been handled.
  Uses `:sys.get_state/1` which blocks until the process has processed its mailbox.
  """
  def sync(pid), do: :sys.get_state(pid)

  @doc """
  Assert a process is alive.
  """
  def assert_alive(pid) do
    assert Process.alive?(pid), "Expected process #{inspect(pid)} to be alive"
  end

  @doc """
  Monitor a process, stop it, and wait for the DOWN message.
  """
  def stop_and_await(pid, reason \\ :normal) do
    ref = Process.monitor(pid)
    GenServer.stop(pid, reason)
    assert_receive {:DOWN, ^ref, :process, ^pid, ^reason}, 5_000
  end

  @doc """
  Monitor a process and return the monitor ref.
  Use with `assert_receive {:DOWN, ^ref, :process, ^pid, :normal}`.
  """
  def monitor_process(pid), do: Process.monitor(pid)
end
