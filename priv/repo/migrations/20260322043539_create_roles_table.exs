defmodule Aya.Repo.Migrations.CreateRolesTable do
  use OmMigration

  import Aya.Constants

  def change do
    create table(:roles, primary_key: false) do
      uuid_primary_key()

      add :account_id, references(:accounts, type: :uuid, on_delete: :delete_all),
        default: fragment("'#{default_account_id_const()}'::uuid")

      add :name, :citext, null: false
      add :slug, :citext, null: false
      add :description, :text
      add :permissions, :jsonb, default: fragment("'{}'"), null: false
      add :is_system, :boolean, null: false, default: false

      status_fields(only: [:status], default: "active", null: false)
      type_fields(only: [:type, :subtype])
      metadata_field()
      assets_field()
      audit_fields(default_urm_id: system_urm_id_const())

      timestamps()
    end

    create unique_index(:roles, [:slug])
    create unique_index(:roles, [:account_id, :name])
    create index(:roles, [:account_id])
    create index(:roles, [:is_system])
    status_field_indexes(:roles, only: [:status])
    type_field_indexes(:roles, only: [:type, :subtype])
    audit_field_indexes(:roles)
    timestamp_indexes(:roles)
  end
end
