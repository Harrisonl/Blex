defmodule Blex.Admin.SettingsControllerTest do
  use Blex.ConnCase, async: false

  alias Blex.{User, TestUtils}

  describe "index" do
    @tag :success
    test "lists all the settings" do
      user = TestUtils.create_user
      conn = Guardian.Plug.api_sign_in(build_conn(), user)
      conn = get conn, admin_settings_path(conn, :index)
      assert html_response(conn, 200) =~ "Settings"
    end

    @tag :failure
    test "redirect to the login page", %{conn: conn} do
      conn = get conn, admin_settings_path(conn, :index)
      assert html_response(conn, 302) =~ "You are being <a href=\"/login\">redirected</a>"
    end
  end

  describe "update" do

    setup do
      TestUtils.wipe_models
      user = TestUtils.create_user
      conn = Guardian.Plug.api_sign_in(build_conn(), user)
      %{:ok, %{conn: conn}}
    end

    @tag :success
    test "creates a new user with valid attrs", %{conn: conn} do
      put conn, admin_settings_path(conn, :update), user: @registration_valid_attrs
      assert Repo.all(User) |> length == 1
    end

    @tag :success
    test "redirects to the index for success", %{conn: conn} do
      conn = post conn, admin_user_path(conn, :create), user: @registration_valid_attrs
      assert html_response(conn, 302)
    end

    @tag :failure
    test "errors for invalid password length", %{conn: conn} do
      post conn, admin_user_path(conn, :create), user: @registration_invalid_attrs
      assert Repo.all(User) |> length == 0
    end

    @tag :success
    test "renders new for a failed create", %{conn: conn} do
      conn = post conn, admin_user_path(conn, :create), user: @registration_invalid_attrs
      assert html_response(conn, 200) =~ "password"
    end
  end
end

