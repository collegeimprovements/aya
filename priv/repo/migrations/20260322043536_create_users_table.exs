defmodule Aya.Repo.Migrations.CreateUsersTable do
  use OmMigration

  import Aya.Constants

  def change do
    create table(:users, primary_key: false) do
      uuid_primary_key()

      add :email, :citext, null: false
      add :username, :citext
      add :hashed_password, :string, redact: true
      add :confirmed_at, :utc_datetime_usec

      status_fields(only: [:status], default: "active", null: false)
      type_fields(only: [:type, :subtype])
      metadata_field()
      assets_field()
      audit_fields(default_urm_id: system_urm_id_const())

      timestamps()
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:username])
    create index(:users, [:confirmed_at])
    status_field_indexes(:users, only: [:status])
    type_field_indexes(:users, only: [:type, :subtype])
    audit_field_indexes(:users)
    timestamp_indexes(:users)
  end
end
