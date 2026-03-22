defmodule Aya.Repo do
  use Ecto.Repo,
    otp_app: :aya,
    adapter: Ecto.Adapters.Postgres
end
