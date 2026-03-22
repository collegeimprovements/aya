defmodule Aya.Repo.Migrations.CreateAccountsTable do
  use OmMigration

  import Aya.Constants

  def change do
    create table(:accounts, primary_key: false) do
      uuid_primary_key()

      add :name, :citext, null: false
      add :slug, :citext, null: false

      status_fields(only: [:status], default: "active", null: false)
      type_fields(only: [:type, :subtype])
      metadata_field()
      assets_field()
      audit_fields(default_urm_id: system_urm_id_const())

      timestamps()
    end

    create unique_index(:accounts, [:slug])
    status_field_indexes(:accounts, only: [:status])
    type_field_indexes(:accounts, only: [:type, :subtype])
    audit_field_indexes(:accounts)
    timestamp_indexes(:accounts)
  end
end
