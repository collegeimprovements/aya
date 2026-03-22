defmodule Aya.Repo.Migrations.CreateMembershipsTable do
  use OmMigration

  import Aya.Constants

  def change do
    create table(:memberships, primary_key: false) do
      uuid_primary_key()

      add :account_id, references(:accounts, type: :uuid, on_delete: :delete_all),
        null: false,
        default: fragment("'#{default_account_id_const()}'::uuid")

      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false

      add :joined_at, :utc_datetime_usec

      status_fields(only: [:status], default: "active", null: false)
      type_fields(only: [:type, :subtype])
      metadata_field()
      assets_field()
      audit_fields(default_urm_id: system_urm_id_const())

      timestamps()
    end

    create unique_index(:memberships, [:account_id, :user_id])
    create index(:memberships, [:account_id])
    create index(:memberships, [:user_id])
    status_field_indexes(:memberships, only: [:status])
    type_field_indexes(:memberships, only: [:type, :subtype])
    audit_field_indexes(:memberships)
    timestamp_indexes(:memberships)
  end
end
