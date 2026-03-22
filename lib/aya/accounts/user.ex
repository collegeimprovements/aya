defmodule Aya.Accounts.User do
  @moduledoc """
  Schema for users.

  Users are not account-scoped — they can belong to multiple accounts
  via memberships (GitHub org model).

  ## Security Features

  - **Login tracking**: `last_login_at`, `last_login_ip`, `login_count`
  - **Account lockout**: After 5 failed attempts, account locks for 30 minutes
  - **Audit fields**: `password_changed_at` tracks password changes

  ## User Defaults

  Users can set a preferred account and role via `default_account_id` and
  `default_role_id`. These are used when the user logs in without specifying
  a context.
  """

  @derive {FnTypes.Protocols.Identifiable, type: :user}

  use OmSchema

  @types [:human, :system, :service]
  @subtypes [:standard, :admin, :bot, :sso]
  @statuses [:active, :suspended, :deleted]

  @max_failed_attempts 5
  @lockout_duration_minutes 30

  @type t :: %__MODULE__{}

  schema "users" do
    field :email, :string,
      required: true,
      max_length: 160,
      mappers: [:trim, :downcase],
      format: :email,
      unique: :users_email_index

    field :username, :string,
      min_length: 3,
      max_length: 30,
      format: ~r/^[a-zA-Z0-9_]+$/,
      unique: :users_username_index

    field :hashed_password, :string, redact: true, cast: false, trim: false
    field :confirmed_at, :utc_datetime_usec

    field :password, :string,
      virtual: true,
      redact: true,
      trim: false,
      min_length: 12,
      max_length: 72

    # Security audit fields
    field :last_login_at, :utc_datetime_usec
    field :last_login_ip, :string
    field :login_count, :integer, default: 0
    field :failed_login_attempts, :integer, default: 0
    field :locked_at, :utc_datetime_usec
    field :lock_reason, :string
    field :password_changed_at, :utc_datetime_usec

    type_fields()
    status_fields(values: @statuses, default: :active)
    metadata_field()
    assets_field()
    audit_fields()
    timestamps()

    # User defaults
    belongs_to :default_account, Aya.Accounts.Account,
      foreign_key: :default_account_id,
      on_replace: :nilify

    belongs_to :default_role, Aya.Accounts.Role,
      foreign_key: :default_role_id,
      on_replace: :nilify

    has_many :memberships, Aya.Accounts.Membership, expect_on_delete: :cascade
    has_many :accounts, through: [:memberships, :account]

    has_many :user_role_mappings, Aya.Accounts.UserRoleMapping, expect_on_delete: :cascade

    has_many :roles, through: [:user_role_mappings, :role]
    has_many :tokens, Aya.Accounts.UserToken, expect_on_delete: :cascade
  end

  # ── Registration & Auth Changesets ──────────────────────────

  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> base_changeset(attrs, cast: [:password], required: [:password])
    |> maybe_validate_unique(opts)
    |> maybe_hash_password(opts)
  end

  def email_changeset(user, attrs, opts \\ []) do
    user
    |> base_changeset(attrs, only_cast: [:email], only_required: [:email])
    |> maybe_validate_unique(opts)
  end

  def password_changeset(user, attrs, opts \\ []) do
    user
    |> base_changeset(attrs, only_cast: [:password], only_required: [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> maybe_hash_password(opts)
  end

  def confirm_changeset(user) do
    now = DateTime.utc_now() |> DateTime.truncate(:microsecond)
    change(user, confirmed_at: now)
  end

  def validate_current_password(changeset, password) do
    case valid_password?(changeset.data, password) do
      true -> changeset
      false -> add_error(changeset, :current_password, "is not valid")
    end
  end

  def valid_password?(%__MODULE__{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _), do: Bcrypt.no_user_verify()

  # ── Security Changesets ─────────────────────────────────────

  @spec login_success_changeset(t(), String.t() | nil) :: Ecto.Changeset.t()
  def login_success_changeset(user, ip_address \\ nil) do
    now = DateTime.utc_now() |> DateTime.truncate(:microsecond)

    user
    |> change()
    |> put_change(:last_login_at, now)
    |> put_change(:last_login_ip, ip_address)
    |> put_change(:login_count, (user.login_count || 0) + 1)
    |> put_change(:failed_login_attempts, 0)
    |> put_change(:locked_at, nil)
    |> put_change(:lock_reason, nil)
  end

  @spec login_failure_changeset(t()) :: Ecto.Changeset.t()
  def login_failure_changeset(user) do
    attempts = (user.failed_login_attempts || 0) + 1
    changeset = change(user, failed_login_attempts: attempts)

    case attempts >= @max_failed_attempts do
      true ->
        now = DateTime.utc_now() |> DateTime.truncate(:microsecond)

        changeset
        |> put_change(:locked_at, now)
        |> put_change(:lock_reason, "too_many_failed_attempts")

      false ->
        changeset
    end
  end

  @spec unlock_changeset(t()) :: Ecto.Changeset.t()
  def unlock_changeset(user) do
    change(user,
      locked_at: nil,
      lock_reason: nil,
      failed_login_attempts: 0
    )
  end

  @spec defaults_changeset(t(), map()) :: Ecto.Changeset.t()
  def defaults_changeset(user, attrs) do
    user
    |> cast(attrs, [:default_account_id, :default_role_id])
    |> foreign_key_constraint(:default_account_id)
    |> foreign_key_constraint(:default_role_id)
  end

  # ── Security Predicates ─────────────────────────────────────

  @spec locked?(t()) :: boolean()
  def locked?(%__MODULE__{locked_at: nil}), do: false

  def locked?(%__MODULE__{locked_at: locked_at}) do
    lockout_expires = DateTime.add(locked_at, @lockout_duration_minutes, :minute)
    DateTime.compare(DateTime.utc_now(), lockout_expires) == :lt
  end

  @spec lockout_remaining_minutes(t()) :: non_neg_integer()
  def lockout_remaining_minutes(%__MODULE__{locked_at: nil}), do: 0

  def lockout_remaining_minutes(%__MODULE__{locked_at: locked_at}) do
    lockout_expires = DateTime.add(locked_at, @lockout_duration_minutes, :minute)
    diff = DateTime.diff(lockout_expires, DateTime.utc_now(), :minute)
    max(0, diff)
  end

  def max_failed_attempts, do: @max_failed_attempts
  def lockout_duration_minutes, do: @lockout_duration_minutes

  # ── Private ─────────────────────────────────────────────────

  defp maybe_validate_unique(changeset, opts) do
    case Keyword.get(opts, :validate_unique, true) do
      true ->
        changeset
        |> unsafe_validate_unique(:email, Aya.Repo)
        |> unsafe_validate_unique(:username, Aya.Repo)
        |> unique_constraints([{:email, []}, {:username, []}])

      false ->
        changeset
    end
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    case {hash_password?, password, changeset.valid?} do
      {true, password, true} when is_binary(password) ->
        changeset
        |> validate_length(:password, max: 72, count: :bytes)
        |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
        |> delete_change(:password)

      _ ->
        changeset
    end
  end

  def types, do: @types
  def subtypes, do: @subtypes
  def statuses, do: @statuses
end
