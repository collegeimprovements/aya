defmodule Aya.Accounts.UserToken do
  @moduledoc """
  Schema for user authentication tokens.

  Follows the phx.gen.auth pattern for session management and email tokens.
  """

  @derive {FnTypes.Protocols.Identifiable, type: :user_token}

  use OmSchema
  import Ecto.Query

  @hash_algorithm :sha256
  @rand_size 32

  # Token validity periods
  @session_validity_in_days 60
  @confirm_validity_in_days 7
  @reset_password_validity_in_days 1
  @change_email_validity_in_days 7

  @type t :: %__MODULE__{}

  schema "users_tokens" do
    field :token, :binary
    field :context, :string
    field :sent_to, :string

    belongs_to :user, Aya.Accounts.User

    timestamps(only: [:inserted_at])
  end

  @doc "Generates a session token for signed storage (session/cookie)."
  def build_session_token(user) do
    token = :crypto.strong_rand_bytes(@rand_size)
    {token, %__MODULE__{token: token, context: "session", user_id: user.id}}
  end

  @doc "Verifies a session token and returns a user lookup query."
  def verify_session_token_query(token) do
    query =
      from t in by_token_and_context_query(token, "session"),
        join: user in assoc(t, :user),
        where: t.inserted_at > ago(@session_validity_in_days, "day"),
        select: user

    {:ok, query}
  end

  @doc "Builds a hashed token for email delivery."
  def build_email_token(user, context) do
    build_hashed_token(user, context, user.email)
  end

  defp build_hashed_token(user, context, sent_to) do
    token = :crypto.strong_rand_bytes(@rand_size)
    hashed_token = :crypto.hash(@hash_algorithm, token)

    {Base.url_encode64(token, padding: false),
     %__MODULE__{
       token: hashed_token,
       context: context,
       sent_to: sent_to,
       user_id: user.id
     }}
  end

  @doc "Verifies an email token and returns a user lookup query."
  def verify_email_token_query(token, context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)
        days = days_for_context(context)

        query =
          from t in by_token_and_context_query(hashed_token, context),
            join: user in assoc(t, :user),
            where: t.inserted_at > ago(^days, "day") and t.sent_to == user.email,
            select: user

        {:ok, query}

      :error ->
        :error
    end
  end

  defp days_for_context("confirm"), do: @confirm_validity_in_days
  defp days_for_context("reset_password"), do: @reset_password_validity_in_days

  @doc "Verifies a change-email token."
  def verify_change_email_token_query(token, "change:" <> _ = context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)

        query =
          from t in by_token_and_context_query(hashed_token, context),
            where: t.inserted_at > ago(@change_email_validity_in_days, "day")

        {:ok, query}

      :error ->
        :error
    end
  end

  def by_token_and_context_query(token, context) do
    from __MODULE__, where: [token: ^token, context: ^context]
  end

  def by_user_and_contexts_query(user, :all) do
    from t in __MODULE__, where: t.user_id == ^user.id
  end

  def by_user_and_contexts_query(user, [_ | _] = contexts) do
    from t in __MODULE__, where: t.user_id == ^user.id and t.context in ^contexts
  end
end
