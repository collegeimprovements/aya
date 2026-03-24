defmodule Aya.Health do
  @moduledoc """
  System health checks for Aya.

  Defines critical and optional service checks used by the health
  endpoint (`/api/health`) and Docker/K8s probes.

  ## Usage

      Aya.Health.check_all()       # full health report
      Aya.Health.overall_status()  # :healthy | :degraded | :unhealthy
      Aya.Health.display()         # formatted console output
  """

  use OmHealth

  config do
    app_name(:aya)
    repo(Aya.Repo)
    endpoint(AyaWeb.Endpoint)
    cache(Aya.Cache)
  end

  services do
    service(:database,
      module: Aya.Repo,
      type: :repo,
      critical: true
    )

    service(:cache,
      module: Aya.Cache,
      type: :cache,
      critical: false
    )

    service(:pubsub,
      module: Aya.PubSub,
      type: :pubsub,
      critical: false
    )

    service(:endpoint,
      module: AyaWeb.Endpoint,
      type: :endpoint,
      critical: true
    )
  end
end
