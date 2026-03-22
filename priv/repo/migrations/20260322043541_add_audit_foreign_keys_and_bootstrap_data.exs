defmodule Aya.Repo.Migrations.AddAuditForeignKeysAndBootstrapData do
  use OmMigration

  import Aya.Constants

  def up do
    now = DateTime.utc_now() |> DateTime.truncate(:microsecond) |> DateTime.to_iso8601()

    # 1. Default Account
    execute """
    INSERT INTO accounts (id, name, slug, status, metadata, assets, created_by_urm_id, updated_by_urm_id, inserted_at, updated_at)
    VALUES (
      '#{default_account_id_const()}', 'Default', 'default', 'active',
      '{}', '{}', '#{system_urm_id_const()}', '#{system_urm_id_const()}', '#{now}', '#{now}'
    ) ON CONFLICT (id) DO NOTHING
    """

    # 2. System User (no password — cannot login)
    execute """
    INSERT INTO users (id, email, username, status, metadata, assets, created_by_urm_id, updated_by_urm_id, inserted_at, updated_at)
    VALUES (
      '#{system_user_id_const()}', 'system@localhost', 'system', 'active',
      '{}', '{}', '#{system_urm_id_const()}', '#{system_urm_id_const()}', '#{now}', '#{now}'
    ) ON CONFLICT (id) DO NOTHING
    """

    # 3. System Membership
    execute """
    INSERT INTO memberships (id, account_id, user_id, status, joined_at, metadata, assets, created_by_urm_id, updated_by_urm_id, inserted_at, updated_at)
    VALUES (
      uuidv7(), '#{default_account_id_const()}', '#{system_user_id_const()}', 'active', '#{now}',
      '{}', '{}', '#{system_urm_id_const()}', '#{system_urm_id_const()}', '#{now}', '#{now}'
    ) ON CONFLICT (account_id, user_id) DO NOTHING
    """

    # 4. System Role (super_admin)
    execute """
    INSERT INTO roles (id, account_id, name, slug, description, permissions, status, is_system, metadata, assets, created_by_urm_id, updated_by_urm_id, inserted_at, updated_at)
    VALUES (
      '#{system_role_id_const()}', '#{default_account_id_const()}', 'Super Admin', 'super_admin',
      'System administrator with full access', '{"*": true}', 'active', true,
      '{}', '{}', '#{system_urm_id_const()}', '#{system_urm_id_const()}', '#{now}', '#{now}'
    ) ON CONFLICT (id) DO NOTHING
    """

    # 5. System URM
    execute """
    INSERT INTO user_role_mappings (id, user_id, role_id, account_id, metadata, assets, created_by_urm_id, updated_by_urm_id, inserted_at, updated_at)
    VALUES (
      '#{system_urm_id_const()}', '#{system_user_id_const()}', '#{system_role_id_const()}', '#{default_account_id_const()}',
      '{}', '{}', '#{system_urm_id_const()}', '#{system_urm_id_const()}', '#{now}', '#{now}'
    ) ON CONFLICT (id) DO NOTHING
    """

    # Add deferred FK constraints for audit fields
    for table <- ~w(accounts users memberships roles user_role_mappings) do
      execute """
      ALTER TABLE #{table}
      ADD CONSTRAINT #{table}_created_by_urm_id_fkey
      FOREIGN KEY (created_by_urm_id) REFERENCES user_role_mappings(id)
      ON DELETE SET NULL DEFERRABLE INITIALLY DEFERRED
      """

      execute """
      ALTER TABLE #{table}
      ADD CONSTRAINT #{table}_updated_by_urm_id_fkey
      FOREIGN KEY (updated_by_urm_id) REFERENCES user_role_mappings(id)
      ON DELETE SET NULL DEFERRABLE INITIALLY DEFERRED
      """
    end
  end

  def down do
    for table <- ~w(accounts users memberships roles user_role_mappings) do
      execute "ALTER TABLE #{table} DROP CONSTRAINT IF EXISTS #{table}_created_by_urm_id_fkey"
      execute "ALTER TABLE #{table} DROP CONSTRAINT IF EXISTS #{table}_updated_by_urm_id_fkey"
    end

    execute "DELETE FROM user_role_mappings WHERE id = '#{system_urm_id_const()}'"
    execute "DELETE FROM roles WHERE id = '#{system_role_id_const()}'"

    execute "DELETE FROM memberships WHERE account_id = '#{default_account_id_const()}' AND user_id = '#{system_user_id_const()}'"

    execute "DELETE FROM users WHERE id = '#{system_user_id_const()}'"
    execute "DELETE FROM accounts WHERE id = '#{default_account_id_const()}'"
  end
end
