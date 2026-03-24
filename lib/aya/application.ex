defmodule Aya.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        AyaWeb.Telemetry,
        Aya.Repo,
        {DNSCluster, query: Application.get_env(:aya, :dns_cluster_query) || :ignore},
        {Phoenix.PubSub, name: Aya.PubSub},
        Aya.Cache
      ] ++
        maybe_scheduler() ++
        [AyaWeb.Endpoint]

    opts = [strategy: :one_for_one, name: Aya.Supervisor]
    result = Supervisor.start_link(children, opts)

    maybe_migrate()

    result
  end

  @impl true
  def config_change(changed, _new, removed) do
    AyaWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp maybe_scheduler do
    if Application.get_env(:om_scheduler, :enabled, false) do
      [OmScheduler.Supervisor]
    else
      []
    end
  end

  defp maybe_migrate do
    if Application.get_env(:aya, :auto_migrate, false) do
      Aya.Release.migrate()
    end
  end
end
