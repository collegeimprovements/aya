defmodule Aya.Release do
  @moduledoc """
  Release tasks for database migrations.

  Can be invoked from the release binary or via IEx:

      # Run all pending migrations
      Aya.Release.migrate()

      # Run N migrations
      Aya.Release.migrate(3)

      # Rollback last migration
      Aya.Release.rollback_step()

      # Rollback last N migrations
      Aya.Release.rollback_step(3)

      # Rollback all migrations
      Aya.Release.rollback_all()

      # Rollback to a specific version
      Aya.Release.rollback(Aya.Repo, 20260322043530)

      # Check migration status
      Aya.Release.migration_status()

  From the release binary:

      bin/aya eval "Aya.Release.migrate()"
      bin/aya eval "Aya.Release.migration_status()"
  """

  @app :aya

  @doc "Run all pending migrations."
  @spec migrate() :: :ok
  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end

    :ok
  end

  @doc "Run the next `n` pending migrations."
  @spec migrate(pos_integer()) :: :ok
  def migrate(n) when is_integer(n) and n > 0 do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, step: n))
    end

    :ok
  end

  @doc "Rollback to a specific migration version."
  @spec rollback(module(), non_neg_integer()) :: :ok
  def rollback(repo \\ Aya.Repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
    :ok
  end

  @doc "Rollback the last `n` migrations (default 1)."
  @spec rollback_step(pos_integer()) :: :ok
  def rollback_step(n \\ 1) when is_integer(n) and n > 0 do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, step: n))
    end

    :ok
  end

  @doc "Rollback all migrations."
  @spec rollback_all() :: :ok
  def rollback_all do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, all: true))
    end

    :ok
  end

  @doc "Print the status of all migrations."
  @spec migration_status() :: [{module(), [{:up | :down, non_neg_integer(), String.t()}]}]
  def migration_status do
    load_app()

    for repo <- repos() do
      {:ok, migrations, _} =
        Ecto.Migrator.with_repo(repo, fn repo ->
          Ecto.Migrator.migrations(repo)
        end)

      IO.puts("\n== #{inspect(repo)} ==\n")

      Enum.each(migrations, fn {status, version, name} ->
        IO.puts("  #{status}\t#{version}\t#{name}")
      end)

      {repo, migrations}
    end
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.ensure_all_started(:ssl)
    Application.load(@app)
  end
end
