defmodule Blex.Admin.SettingsControllerTest do
  use Blex.ConnCase, async: false

  alias Blex.{TestUtils, SettingsCache}

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
      {:ok, %{conn: conn}}
    end

    @tag :success
    test "renders the index", %{conn: conn} do
      conn = put conn, admin_settings_path(conn, :update), settings: %{blog_name: "Bob's Blog", blog_tagline: "The greatest out there"}
      assert html_response(conn, 200) =~ "Settings"
    end

    @tag :success
    test "updates settings", %{conn: conn} do
      put conn, admin_settings_path(conn, :update), settings: %{blog_name: "Bob's Blog", blog_tagline: "The greatest out there"}
      assert SettingsCache.get_setting(:blog_name) == {:ok, "Bob's Blog"}
      assert SettingsCache.get_setting(:blog_tagline) == {:ok, "The greatest out there"}
    end
  end
end

