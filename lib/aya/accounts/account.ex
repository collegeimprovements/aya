defmodule Aya.Accounts.Account do
  @moduledoc """
  Schema for accounts (tenants).

  Accounts represent organizations/tenants in the multi-tenant system.
  A default account is seeded for single-tenant deployments.
  """

  @derive {FnTypes.Protocols.Identifiable, type: :account}

  use OmSchema

  @types [:personal, :organization, :enterprise]
  @subtypes [:free, :pro, :business]
  @statuses [:active, :suspended, :deleted]

  @type t :: %__MODULE__{}

  schema "accounts" do
    field :name, :string, required: true
    field :slug, :string, required: true, format: :slug, unique: :accounts_slug_index

    type_fields()
    status_fields(values: @statuses, default: :active)
    metadata_field()
    assets_field()
    audit_fields()
    timestamps()

    has_many :memberships, Aya.Accounts.Membership, expect_on_delete: :cascade
    has_many :users, through: [:memberships, :user]
    has_many :roles, Aya.Accounts.Role, expect_on_delete: :cascade

    has_many :user_role_mappings, Aya.Accounts.UserRoleMapping, expect_on_delete: :cascade
  end

  def changeset(account, attrs) do
    account
    |> base_changeset(attrs)
    |> unique_constraints([{:slug, []}])
  end

  def types, do: @types
  def subtypes, do: @subtypes
  def statuses, do: @statuses
end
