defmodule Blex.SessionControllerTest do
  use Blex.ConnCase, async: false

  alias Blex.{User, Repo}
  @valid_attrs %{bio: "some content", email: "alice@test.com", github: "some content", password: "12345678", name: "some content", role: "some content", twitter: "some content"}
  @invalid_attrs %{}

  setup do
    user = User.registration_changeset(%User{}, @valid_attrs) |> Repo.insert! 
    {:ok, %{user: user}}
  end

  describe "Create/2" do
    test "should log the user in with valid attrs", %{conn: conn} do
      session_params = %{"session" => %{"email" => "alice@test.com", "password" => "12345678"}}
      conn = post conn, session_path(conn, :create), session_params
      assert html_response(conn, 302)
    end

    test "should not log the user in with invalid attrs", %{conn: conn} do
      session_params = %{"session" => %{"email" => "alice@test.com", "password" => "87654321"}}
      conn = post conn, session_path(conn, :create), session_params
      assert html_response(conn, 422)
    end
  end

  describe "delete/2" do
    test "should log the user out with valid attrs", %{conn: conn} do
      conn = get conn, signout_session_path(conn, :delete)
      assert html_response(conn, 302)
    end
  end
end
