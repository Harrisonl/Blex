defmodule Blex.AuthenticatorTest do
  use ExUnit.Case, async: false
  alias Blex.{TestUtils, Authenticator, Repo}


  setup_all do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Repo, { :shared, self() })
    :ok
  end

  describe "check_pw/1" do

    setup do
      TestUtils.wipe_models
      user = TestUtils.create_user
      {:ok, %{user: user}}
    end

    @tag :success
    test "user is valid and valid password", %{user: user} do
      assert {:ok, true, ^user} = Authenticator.check_pw(user, "12345678")
    end

    @tag :success
    test "user is valid but invalid password", %{user: user} do
      assert {:ok, false, ^user} = Authenticator.check_pw(user, "145678")
    end

    @tag :failure
    test "neither user or password is valid" do
      assert {:error, false, nil} = Authenticator.check_pw(nil, "145678")
    end
  end
end
