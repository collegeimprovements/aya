defmodule Aya.Cache do
  @moduledoc """
  Application cache backed by Nebulex.

  Uses ETS (local adapter) by default — no external services needed for
  dev/test. For production with Redis, change `default_adapter: :redis`
  and set `REDIS_HOST` / `REDIS_PORT` environment variables.

  ## Usage

      Aya.Cache.put({User, 123}, user, ttl: :timer.minutes(15))
      Aya.Cache.get({User, 123})

  ## With result tuples

      OmCache.Helpers.fetch(Aya.Cache, {User, 123})
      OmCache.Helpers.put_safe(Aya.Cache, {User, 123}, user, ttl: :timer.minutes(15))
  """

  use OmCache, otp_app: :aya, default_adapter: :local
end
