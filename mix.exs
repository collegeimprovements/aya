defmodule Aya.MixProject do
  use Mix.Project

  @libs_path "../../events/libs"

  def project do
    [
      app: :aya,
      version: "0.1.0",
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      compilers: [:phoenix_live_view] ++ Mix.compilers(),
      listeners: [Phoenix.CodeReloader]
    ]
  end

  def application do
    [
      mod: {Aya.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  def cli do
    [
      preferred_envs: [precommit: :test]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # ── Phoenix core ──────────────────────────────────────────
      {:phoenix, "~> 1.8.5"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.13"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_view, "~> 1.1.0"},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:bandit, "~> 1.5"},

      # ── Assets ────────────────────────────────────────────────
      {:esbuild, "~> 0.10", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.3", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.2.0",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},

      # ── Auth ──────────────────────────────────────────────────
      {:bcrypt_elixir, "~> 3.0"},

      # ── HTTP ──────────────────────────────────────────────────
      {:req, "~> 0.5"},

      # ── Email ─────────────────────────────────────────────────
      {:swoosh, "~> 1.16"},

      # ── JSON ──────────────────────────────────────────────────
      {:jason, "~> 1.2"},

      # ── i18n ──────────────────────────────────────────────────
      {:gettext, "~> 1.0"},

      # ── Observability ─────────────────────────────────────────
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},

      # ── Clustering ────────────────────────────────────────────
      {:dns_cluster, "~> 0.2.0"},

      # ── Dev only ──────────────────────────────────────────────
      {:phoenix_live_reload, "~> 1.2", only: :dev},

      # ── Test only ─────────────────────────────────────────────
      {:lazy_html, ">= 0.1.0"},
      {:mimic, "~> 1.10", only: :test},

      # ── Shared libs (events/libs) ─────────────────────────────
      {:fn_types, path: "#{@libs_path}/fn_types"},
      {:fn_decorator, path: "#{@libs_path}/fn_decorator"},
      {:dag, path: "#{@libs_path}/dag"},
      {:effect, path: "#{@libs_path}/effect"},
      {:om_behaviours, path: "#{@libs_path}/om_behaviours"},
      {:om_http, path: "#{@libs_path}/om_http"},
      {:om_api_client, path: "#{@libs_path}/om_api_client"},
      {:om_schema, path: "#{@libs_path}/om_schema"},
      {:om_query, path: "#{@libs_path}/om_query"},
      {:om_crud, path: "#{@libs_path}/om_crud"},
      {:om_migration, path: "#{@libs_path}/om_migration"},
      {:om_rss, path: "#{@libs_path}/om_rss"},
      {:om_cache, path: "#{@libs_path}/om_cache"},
      {:om_scheduler, path: "#{@libs_path}/om_scheduler"},
      {:om_health, path: "#{@libs_path}/om_health"},
      {:om_credo, path: "#{@libs_path}/om_credo", only: [:dev, :test]},
      {:om_middleware, path: "#{@libs_path}/om_middleware"}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["compile", "tailwind aya", "esbuild aya"],
      "assets.deploy": [
        "tailwind aya --minify",
        "esbuild aya --minify",
        "phx.digest"
      ],
      precommit: ["compile --warnings-as-errors", "deps.unlock --unused", "format", "test"]
    ]
  end
end
