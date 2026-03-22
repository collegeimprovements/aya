defmodule Aya.Accounts.UserRoleMapping do
  @moduledoc """
  Schema for user role mappings (URM).

  This is the central table for identity and audit — it assigns roles to users within accounts.
  The URM ID is used throughout the system for audit fields (created_by_urm_id,
  updated_by_urm_id) to track which user+role+account context performed an action.

  All tables and schemas in the accounts context are referenced via URM.
  """

  @derive {FnTypes.Protocols.Identifiable, type: :user_role_mapping}

  use OmSchema

  @types [:permanent, :temporary]
  @subtypes [:direct, :inherited]

  @type t :: %__MODULE__{}

  schema "user_role_mappings" do
    type_fields()
    metadata_field()
    assets_field()
    audit_fields()
    timestamps()

    belongs_to :user, Aya.Accounts.User, on_delete: :cascade
    belongs_to :role, Aya.Accounts.Role, on_delete: :cascade
    belongs_to :account, Aya.Accounts.Account, on_delete: :cascade

    constraints do
      unique([:user_id, :role_id, :account_id],
        name: :user_role_mappings_user_id_role_id_account_id_index
      )
    end
  end

  def changeset(urm, attrs) do
    urm
    |> base_changeset(attrs,
      also_cast: [:user_id, :role_id, :account_id],
      also_required: [:user_id, :role_id, :account_id]
    )
    |> foreign_key_constraints([{:user_id, []}, {:role_id, []}, {:account_id, []}])
    |> unique_constraints([{[:user_id, :role_id, :account_id], []}])
  end

  def types, do: @types
  def subtypes, do: @subtypes
end
