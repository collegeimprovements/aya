defmodule Aya.Repo.Migrations.CreateUsersTokensTable do
  use OmMigration

  def change do
    create table(:users_tokens, primary_key: false) do
      uuid_primary_key()

      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string

      timestamps(updated_at: false)
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:token, :context])
    create index(:users_tokens, [:context])
    create index(:users_tokens, [:user_id, :context])
  end
end
