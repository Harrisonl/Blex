defmodule Blex.Admin.UserControllerTest do
  use Blex.ConnCase, async: false

  alias Blex.{User, Repo, TestUtils}

  @valid_attrs %{bio: "some content", email: "some content", github: "some content", name: "some content", role: "some content", twitter: "some content"}
  @invalid_attrs %{}

  @registration_valid_attrs %{bio: "some content", email: "some content", github: "some content", name: "some content", role: "some content", twitter: "some content", password: "12345678"}
  @registration_invalid_attrs %{bio: "some content", email: "some content", github: "some content", name: "some content", role: "some content", twitter: "some content", password: "123458"}

  describe "index" do
    @tag :success
    test "lists all users", %{conn: conn} do
      conn = get conn, admin_user_path(conn, :index)
      assert html_response(conn, 200) =~ "Users"
    end
  end

  describe "new" do
    @tag :success
    test "renders the new template", %{conn: conn} do
      conn = get conn, admin_user_path(conn, :new)
      assert html_response(conn, 200) =~ "password"
    end
  end

  describe "create" do

    setup do
      TestUtils.wipe_models
      :ok
    end

    @tag :success
    test "creates a new user with valid attrs", %{conn: conn} do
      post conn, admin_user_path(conn, :create), user: @registration_valid_attrs
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
