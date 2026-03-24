import Config
alias FnTypes.Config, as: Cfg

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere.

# ── Server ────────────────────────────────────────────────────────
# Guarded to non-test: test uses fixed port 4002 / server: false
# from config.exs and must not be overridden by env vars.

if config_env() != :test do
  if Cfg.boolean("PHX_SERVER", false) do
    config :aya, AyaWeb.Endpoint, server: true
  end

  config :aya, AyaWeb.Endpoint, http: [port: Cfg.integer("PORT", 4000)]
end

config :aya, auto_migrate: Cfg.boolean("AUTO_MIGRATE", false)

# ══════════════════════════════════════════════════════════════════
# Dev
# ══════════════════════════════════════════════════════════════════

if config_env() == :dev do
  config :aya, Aya.Repo,
    username: "postgres",
    password: "postgres",
    hostname: "localhost",
    database: "aya_dev",
    stacktrace: true,
    show_sensitive_data_on_connection_error: true,
    pool_size: 10

  config :aya, Aya.Cache, stats: true

  config :om_scheduler,
    enabled: true,
    store: :memory,
    queues: [default: 5],
    plugins: [OmScheduler.Plugins.Cron]
end

# ══════════════════════════════════════════════════════════════════
# Test
# ══════════════════════════════════════════════════════════════════

if config_env() == :test do
  config :aya, Aya.Repo,
    username: "postgres",
    password: "postgres",
    hostname: "localhost",
    database: "aya_test#{Cfg.string("MIX_TEST_PARTITION")}",
    pool: Ecto.Adapters.SQL.Sandbox,
    pool_size: System.schedulers_online() * 2

  config :aya, Aya.Mailer, adapter: Swoosh.Adapters.Test
  config :aya, Aya.Cache, stats: false
  config :om_scheduler, enabled: false
  config :logger, level: :warning
end

# ══════════════════════════════════════════════════════════════════
# Prod
# ══════════════════════════════════════════════════════════════════

if config_env() == :prod do
  database_url =
    Cfg.string!("DATABASE_URL",
      message: "DATABASE_URL is missing. Example: ecto://USER:PASS@HOST/DATABASE"
    )

  config :aya, Aya.Repo,
    url: database_url,
    ssl: Cfg.boolean("ECTO_SSL", false),
    pool_size: Cfg.integer("POOL_SIZE", 10),
    socket_options: [:inet]

  secret_key_base =
    Cfg.string!("SECRET_KEY_BASE",
      message: "SECRET_KEY_BASE is missing. Generate with: mix phx.gen.secret"
    )

  host = Cfg.string("PHX_HOST", "localhost")
  port = Cfg.integer("PORT", 4000)
  https? = Cfg.boolean("PHX_HTTPS", false)
  scheme = if https?, do: "https", else: "http"
  url_port = if https?, do: 443, else: port

  config :aya, :dns_cluster_query, Cfg.string("DNS_CLUSTER_QUERY")

  config :aya, AyaWeb.Endpoint,
    url: [host: host, port: url_port, scheme: scheme],
    http: [ip: {0, 0, 0, 0}, port: port],
    secret_key_base: secret_key_base

  if https? do
    ssl_key = Cfg.string!("SSL_KEY_PATH", message: "SSL_KEY_PATH required when PHX_HTTPS=true")
    ssl_cert = Cfg.string!("SSL_CERT_PATH", message: "SSL_CERT_PATH required when PHX_HTTPS=true")

    config :aya, AyaWeb.Endpoint,
      https: [
        ip: {0, 0, 0, 0},
        port: Cfg.integer("PHX_HTTPS_PORT", 443),
        cipher_suite: :strong,
        keyfile: ssl_key,
        certfile: ssl_cert
      ]
  end

  # ── OmCache ──────────────────────────────────────────────────
  config :aya, Aya.Cache, OmCache.Config.build(default_adapter: :local)

  # ── OmScheduler ──────────────────────────────────────────────
  scheduler_store =
    Cfg.atom("SCHEDULER_STORE", :memory)

  config :om_scheduler,
    enabled: Cfg.boolean("SCHEDULER_ENABLED", false),
    store: scheduler_store,
    repo: Aya.Repo,
    queues: [default: Cfg.integer("SCHEDULER_QUEUE_SIZE", 10)],
    plugins: [
      OmScheduler.Plugins.Cron,
      {OmScheduler.Plugins.Pruner, max_age: {7, :days}}
    ]

  # ── OmApiClient ──────────────────────────────────────────────
  config :om_api_client,
    timeout: Cfg.integer("API_CLIENT_TIMEOUT", 30_000),
    receive_timeout: Cfg.integer("API_CLIENT_RECEIVE_TIMEOUT", 60_000)

  config :logger, level: :info
end
