defmodule AyaWeb.HealthController do
  @moduledoc """
  Health check endpoints for load balancers, Docker, and K8s probes.

  - `GET /api/health`       — detailed service status (200 or 503)
  - `GET /api/health/ready` — readiness probe (200 or 503)
  - `GET /api/health/live`  — liveness probe (always 200)
  """

  use AyaWeb, :controller

  def index(conn, _params) do
    health = Aya.Health.check_all()
    status = Aya.Health.overall_status()
    http_status = if status == :unhealthy, do: 503, else: 200

    conn
    |> put_status(http_status)
    |> json(%{
      status: status,
      services: Enum.map(health.services, &Map.take(&1, [:name, :status, :info, :critical])),
      duration_ms: health.duration_ms
    })
  end

  def ready(conn, _params) do
    status = Aya.Health.overall_status()
    http_status = if status == :unhealthy, do: 503, else: 200

    conn
    |> put_status(http_status)
    |> json(%{status: status})
  end

  def live(conn, _params) do
    json(conn, %{status: :alive})
  end
end
