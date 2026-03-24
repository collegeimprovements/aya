import Config

# ── Application ───────────────────────────────────────────────────

config :aya,
  ecto_repos: [Aya.Repo],
  generators: [timestamp_type: :utc_datetime_usec, binary_id: true]

config :aya, Aya.Repo, migration_timestamps: [type: :utc_datetime_usec]

# ── Shared libraries ─────────────────────────────────────────────

config :om_crud, default_repo: Aya.Repo

config :om_scheduler,
  enabled: false,
  repo: Aya.Repo

config :om_api_client,
  timeout: 30_000,
  receive_timeout: 60_000,
  pool_timeout: 5_000

config :om_health, timeout: 5_000

# ── Endpoint ──────────────────────────────────────────────────────

config :aya, AyaWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: AyaWeb.ErrorHTML, json: AyaWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Aya.PubSub,
  live_view: [signing_salt: "4eBKZIk+"]

# ── Mailer ────────────────────────────────────────────────────────

config :aya, Aya.Mailer, adapter: Swoosh.Adapters.Local

# ── Assets ────────────────────────────────────────────────────────

config :esbuild,
  version: "0.25.4",
  aya: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

config :tailwind,
  version: "4.1.12",
  aya: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# ── Logger ────────────────────────────────────────────────────────

config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# ── Phoenix ───────────────────────────────────────────────────────

config :phoenix, :json_library, Jason

# ══════════════════════════════════════════════════════════════════
# Environment-specific compile-time config
# ══════════════════════════════════════════════════════════════════

if config_env() == :dev do
  config :aya, dev_routes: true

  config :aya, AyaWeb.Endpoint,
    http: [ip: {127, 0, 0, 1}],
    check_origin: false,
    code_reloader: true,
    debug_errors: true,
    secret_key_base: "PNNcyHfVaFbf+R5n2c6Jqc0z9xnXx+mwtKaCEIWp9PKfEazN9a760jnIMMyKoiR8",
    watchers: [
      esbuild: {Esbuild, :install_and_run, [:aya, ~w(--sourcemap=inline --watch)]},
      tailwind: {Tailwind, :install_and_run, [:aya, ~w(--watch)]}
    ],
    live_reload: [
      web_console_logger: true,
      patterns: [
        ~r"priv/static/(?!uploads/).*\.(js|css|png|jpeg|jpg|gif|svg)$",
        ~r"priv/gettext/.*\.po$",
        ~r"lib/aya_web/router\.ex$",
        ~r"lib/aya_web/(controllers|live|components)/.*\.(ex|heex)$"
      ]
    ]

  config :logger, :default_formatter, format: "[$level] $message\n"
  config :phoenix, :stacktrace_depth, 20
  config :phoenix, :plug_init_mode, :runtime

  config :phoenix_live_view,
    debug_heex_annotations: true,
    debug_attributes: true,
    enable_expensive_runtime_checks: true

  config :swoosh, :api_client, false
end

if config_env() == :test do
  config :aya, AyaWeb.Endpoint,
    http: [ip: {127, 0, 0, 1}, port: 4002],
    secret_key_base: "1b5UayFhgOwDQK/ZJIWGT0Fbh0HilQZw5422G+rTeYHLqmjPkqAgOWrFp9nSIH4w",
    server: false

  config :phoenix, :plug_init_mode, :runtime
  config :phoenix, sort_verified_routes_query_params: true
  config :phoenix_live_view, enable_expensive_runtime_checks: true
  config :swoosh, :api_client, false
end

if config_env() == :prod do
  config :aya, AyaWeb.Endpoint, cache_static_manifest: "priv/static/cache_manifest.json"

  if System.get_env("FORCE_SSL", "true") in ~w(true 1) do
    config :aya, AyaWeb.Endpoint,
      force_ssl: [
        rewrite_on: [:x_forwarded_proto],
        exclude: [hosts: ["localhost", "127.0.0.1"]]
      ]
  end

  config :swoosh, api_client: Swoosh.ApiClient.Req
  config :swoosh, local: false
end
