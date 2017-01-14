defmodule Blex.Admin.UserControllerTest do
  use Blex.ConnCase, async: false

  alias Blex.{User, Repo, TestUtils}

  @registration_valid_attrs %{bio: "some content", email: "some content", github: "some content", name: "some content", role: "some content", twitter: "some content", password: "12345678"}
  @registration_invalid_attrs %{bio: "some content", email: "some content", github: "some content", name: "some content", role: "some content", twitter: "some content", password: "123458"}

  describe "index" do
    @tag :success
    test "lists all users" do
      user = TestUtils.create_user
      conn = Guardian.Plug.api_sign_in(build_conn(), user)
      conn = get conn, admin_user_path(conn, :index)
      assert html_response(conn, 200) =~ "Users"
    end
  end

  describe "new" do
    @tag :success
    test "renders the new template" do
      user = TestUtils.create_user
      conn = Guardian.Plug.api_sign_in(build_conn(), user)
      conn = get conn, admin_user_path(conn, :new)
      assert html_response(conn, 200) =~ "password"
    end
  end

  describe "create" do

    setup do
      TestUtils.wipe_models
      user = TestUtils.create_user
      conn = Guardian.Plug.api_sign_in(build_conn(), user)
      {:ok, %{conn: conn}}
    end

    @tag :success
    test "creates a new user with valid attrs", %{conn: conn} do
      post conn, admin_user_path(conn, :create), user: @registration_valid_attrs
      assert Repo.all(User) |> length == 2
    end

    @tag :success
    test "redirects to the index for success", %{conn: conn} do
      conn = post conn, admin_user_path(conn, :create), user: @registration_valid_attrs
      assert html_response(conn, 302)
    end

    @tag :failure
    test "errors for invalid password length", %{conn: conn} do
      post conn, admin_user_path(conn, :create), user: @registration_invalid_attrs
      assert Repo.all(User) |> length == 1
    end

    @tag :success
    test "renders new for a failed create", %{conn: conn} do
      conn = post conn, admin_user_path(conn, :create), user: @registration_invalid_attrs
      assert html_response(conn, 200) =~ "password"
    end
  end
end
