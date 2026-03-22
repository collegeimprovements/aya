defmodule Aya.AccountsTest do
  use Aya.DataCase, async: true

  alias Aya.Accounts
  alias Aya.Accounts.User

  # ── Helpers ──────────────────────────────────────────────────

  defp unique_email, do: "user#{System.unique_integer([:positive])}@example.com"
  defp unique_username, do: "user#{System.unique_integer([:positive])}"
  defp valid_password, do: "valid_password_123"

  defp register_user!(attrs \\ %{}) do
    {:ok, user} =
      Accounts.register_user(
        Map.merge(
          %{
            email: unique_email(),
            username: unique_username(),
            password: valid_password()
          },
          attrs
        )
      )

    user
  end

  defp default_account_id, do: Aya.Constants.default_account_id()
  defp system_role_id, do: Aya.Constants.system_role_id()

  # ── User Registration ───────────────────────────────────────

  describe "register_user/1" do
    test "creates user with valid attrs" do
      email = unique_email()

      {:ok, user} =
        Accounts.register_user(%{
          email: email,
          username: unique_username(),
          password: valid_password()
        })

      assert user.email == email
      assert user.hashed_password != nil
      assert user.password == nil
    end

    test "hashes password" do
      {:ok, user} =
        Accounts.register_user(%{
          email: unique_email(),
          username: unique_username(),
          password: valid_password()
        })

      assert Bcrypt.verify_pass(valid_password(), user.hashed_password)
    end

    test "rejects duplicate email" do
      email = unique_email()
      register_user!(%{email: email})

      {:error, changeset} =
        Accounts.register_user(%{
          email: email,
          username: unique_username(),
          password: valid_password()
        })

      assert %{email: _} = errors_on(changeset)
    end

    test "rejects short password" do
      {:error, changeset} =
        Accounts.register_user(%{
          email: unique_email(),
          username: unique_username(),
          password: "short"
        })

      assert %{password: _} = errors_on(changeset)
    end
  end

  # ── User Lookup ─────────────────────────────────────────────

  describe "get_user_by_email/1" do
    test "returns user for valid email" do
      user = register_user!()
      found = Accounts.get_user_by_email(user.email)

      assert found.id == user.id
    end

    test "returns nil for unknown email" do
      assert Accounts.get_user_by_email("nobody@example.com") == nil
    end
  end

  describe "get_user_by_username/1" do
    test "returns user for valid username" do
      user = register_user!()
      found = Accounts.get_user_by_username(user.username)

      assert found.id == user.id
    end
  end

  # ── Authentication ──────────────────────────────────────────

  describe "authenticate_user/3" do
    test "returns user on valid credentials" do
      user = register_user!()
      {:ok, authed_user} = Accounts.authenticate_user(user.email, valid_password())

      assert authed_user.id == user.id
    end

    test "tracks login success" do
      user = register_user!()

      {:ok, authed_user} =
        Accounts.authenticate_user(user.email, valid_password(), ip_address: "127.0.0.1")

      assert authed_user.login_count == 1
      assert authed_user.last_login_ip == "127.0.0.1"
      assert authed_user.last_login_at != nil
      assert authed_user.failed_login_attempts == 0
    end

    test "returns error on wrong password" do
      user = register_user!()

      assert {:error, :invalid_credentials} =
               Accounts.authenticate_user(user.email, "wrong_password_123")
    end

    test "returns error for non-existent email" do
      assert {:error, :invalid_credentials} =
               Accounts.authenticate_user("nobody@example.com", valid_password())
    end

    test "increments failed attempts on wrong password" do
      user = register_user!()

      {:error, :invalid_credentials} =
        Accounts.authenticate_user(user.email, "wrong_password_123")

      updated = Accounts.get_user_by_email(user.email)
      assert updated.failed_login_attempts == 1
    end

    test "locks account after max failed attempts" do
      user = register_user!()

      for _ <- 1..User.max_failed_attempts() do
        {:error, :invalid_credentials} =
          Accounts.authenticate_user(user.email, "wrong_password_123")
      end

      locked = Accounts.get_user_by_email(user.email)
      assert locked.locked_at != nil
      assert User.locked?(locked)
    end

    test "rejects login on locked account" do
      user = register_user!()

      for _ <- 1..User.max_failed_attempts() do
        Accounts.authenticate_user(user.email, "wrong_password_123")
      end

      assert {:error, :account_locked} = Accounts.authenticate_user(user.email, valid_password())
    end
  end

  describe "unlock_user/1" do
    test "clears lockout state" do
      user = register_user!()

      for _ <- 1..User.max_failed_attempts() do
        Accounts.authenticate_user(user.email, "wrong_password_123")
      end

      locked = Accounts.get_user_by_email(user.email)
      assert User.locked?(locked)

      {:ok, unlocked} = Accounts.unlock_user(locked)
      refute User.locked?(unlocked)
      assert unlocked.failed_login_attempts == 0
    end
  end

  # ── Sessions ────────────────────────────────────────────────

  describe "session tokens" do
    test "generate and verify session token" do
      user = register_user!()
      {:ok, token} = Accounts.generate_user_session_token(user)

      found = Accounts.get_user_by_session_token(token)
      assert found.id == user.id
    end

    test "returns nil for invalid token" do
      assert Accounts.get_user_by_session_token("invalid") == nil
    end

    test "delete session token invalidates it" do
      user = register_user!()
      {:ok, token} = Accounts.generate_user_session_token(user)

      Accounts.delete_user_session_token(token)

      assert Accounts.get_user_by_session_token(token) == nil
    end
  end

  # ── Email Confirmation ──────────────────────────────────────

  describe "confirm_user/1" do
    test "confirms user with valid token" do
      user = register_user!()

      {:ok, encoded_token} =
        Accounts.deliver_user_confirmation_instructions(user, &"/confirm/#{&1}")

      {:ok, confirmed} = Accounts.confirm_user(encoded_token)
      assert confirmed.confirmed_at != nil
    end

    test "rejects invalid token" do
      assert :error = Accounts.confirm_user("invalid_token")
    end

    test "rejects already confirmed user" do
      user = register_user!()
      {:ok, token} = Accounts.deliver_user_confirmation_instructions(user, &"/confirm/#{&1}")
      {:ok, _confirmed} = Accounts.confirm_user(token)

      # Re-fetch user
      confirmed_user = Accounts.get_user_by_email(user.email)

      assert {:error, :already_confirmed} =
               Accounts.deliver_user_confirmation_instructions(confirmed_user, &"/confirm/#{&1}")
    end
  end

  # ── Password Reset ──────────────────────────────────────────

  describe "reset_user_password/2" do
    test "resets password with valid attrs" do
      user = register_user!()
      new_password = "new_password_12345"

      {:ok, updated} = Accounts.reset_user_password(user, %{password: new_password})

      assert Bcrypt.verify_pass(new_password, updated.hashed_password)
    end
  end

  # ── Memberships ─────────────────────────────────────────────

  describe "memberships" do
    test "add and check membership" do
      user = register_user!()

      {:ok, _membership} = Accounts.add_user_to_account(default_account_id(), user.id)

      assert Accounts.member?(default_account_id(), user.id)
    end

    test "list memberships for user" do
      user = register_user!()
      Accounts.add_user_to_account(default_account_id(), user.id)

      memberships = Accounts.list_memberships_for_user(user.id)
      assert length(memberships) == 1
      assert hd(memberships).account_id == default_account_id()
    end

    test "remove membership" do
      user = register_user!()
      Accounts.add_user_to_account(default_account_id(), user.id)

      {:ok, _} = Accounts.remove_user_from_account(default_account_id(), user.id)

      refute Accounts.member?(default_account_id(), user.id)
    end

    test "duplicate membership rejected" do
      user = register_user!()
      {:ok, _} = Accounts.add_user_to_account(default_account_id(), user.id)

      assert {:error, _changeset} = Accounts.add_user_to_account(default_account_id(), user.id)
    end
  end

  # ── Role Assignment ─────────────────────────────────────────

  describe "role assignment" do
    test "assign and check role" do
      user = register_user!()

      {:ok, _urm} = Accounts.assign_role(user.id, system_role_id(), default_account_id())

      assert Accounts.has_role?(user.id, system_role_id(), default_account_id())
    end

    test "list user roles in account" do
      user = register_user!()
      Accounts.assign_role(user.id, system_role_id(), default_account_id())

      roles = Accounts.get_user_roles(user.id, default_account_id())
      assert length(roles) == 1
      assert hd(roles).slug == "super_admin"
    end

    test "remove role" do
      user = register_user!()
      Accounts.assign_role(user.id, system_role_id(), default_account_id())

      {:ok, _} = Accounts.remove_role(user.id, system_role_id(), default_account_id())

      refute Accounts.has_role?(user.id, system_role_id(), default_account_id())
    end

    test "duplicate role assignment rejected" do
      user = register_user!()
      {:ok, _} = Accounts.assign_role(user.id, system_role_id(), default_account_id())

      assert {:error, _changeset} =
               Accounts.assign_role(user.id, system_role_id(), default_account_id())
    end

    test "list URMs for user" do
      user = register_user!()
      Accounts.assign_role(user.id, system_role_id(), default_account_id())

      urms = Accounts.list_urms_for_user(user.id)
      assert length(urms) == 1
      assert hd(urms).role.slug == "super_admin"
    end
  end

  # ── System Bootstrap ────────────────────────────────────────

  describe "bootstrap data" do
    test "system user exists" do
      user = Accounts.get_system_user()
      assert user != nil
      assert user.email == "system@localhost"
    end

    test "system role exists" do
      role = Accounts.get_system_role()
      assert role != nil
      assert role.slug == "super_admin"
      assert role.is_system == true
    end

    test "system URM exists" do
      urm = Accounts.get_system_urm()
      assert urm != nil
      assert urm.user_id == Aya.Constants.system_user_id()
      assert urm.role_id == Aya.Constants.system_role_id()
    end

    test "default account exists" do
      account = Accounts.get_default_account()
      assert account != nil
      assert account.slug == "default"
    end

    test "system role cannot be deleted" do
      role = Accounts.get_system_role()
      assert {:error, :system_role} = Accounts.delete_role(role)
    end
  end

  # ── User Defaults ───────────────────────────────────────────

  describe "user defaults" do
    test "set and retrieve defaults" do
      user = register_user!()

      {:ok, updated} = Accounts.set_user_defaults(user, default_account_id(), system_role_id())

      with_defaults = Accounts.get_user_with_defaults(updated.id)
      assert with_defaults.default_account.slug == "default"
      assert with_defaults.default_role.slug == "super_admin"
    end
  end
end
