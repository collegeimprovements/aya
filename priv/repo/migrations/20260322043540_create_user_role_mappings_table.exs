defmodule Aya.Repo.Migrations.CreateUserRoleMappingsTable do
  use OmMigration

  import Aya.Constants

  def change do
    create table(:user_role_mappings, primary_key: false) do
      uuid_primary_key()

      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :role_id, references(:roles, type: :uuid, on_delete: :delete_all), null: false

      add :account_id, references(:accounts, type: :uuid, on_delete: :delete_all),
        null: false,
        default: fragment("'#{default_account_id_const()}'::uuid")

      type_fields(only: [:type, :subtype])
      metadata_field()
      assets_field()
      audit_fields(default_urm_id: system_urm_id_const())

      timestamps()
    end

    create unique_index(:user_role_mappings, [:user_id, :role_id, :account_id])
    create index(:user_role_mappings, [:user_id])
    create index(:user_role_mappings, [:role_id])
    create index(:user_role_mappings, [:account_id])
    create index(:user_role_mappings, [:user_id, :account_id])
    create index(:user_role_mappings, [:account_id, :role_id])
    type_field_indexes(:user_role_mappings, only: [:type, :subtype])
    audit_field_indexes(:user_role_mappings)
    timestamp_indexes(:user_role_mappings)
  end
end
