defmodule Blex.Admin.PostControllerTest do
  use Blex.ConnCase, async: false

  alias Blex.{Post, User, Repo, TestUtils, PostsCache}

  @valid_attrs %{title: "Test Post", body: "# Markdown", status: "draft", author: "Alice", slug: "test-post"}
  @invalid_attrs %{}

  describe "index" do
    setup do
      post =
        %Post{}
        |> Post.changeset(@valid_attrs)
        |> Repo.insert!
      user = TestUtils.create_user
      conn = Guardian.Plug.api_sign_in(build_conn(), user)
      {:ok, %{post: post, conn: conn}}
    end

    @tag :success
    test "lists all posts", %{conn: conn} do
      conn = get conn, admin_post_path(conn, :index)
      assert html_response(conn, 200) =~ "Test Post"
    end
  end

  describe "new" do
    @tag :success
    test "renders the new template" do
      user = TestUtils.create_user
      conn = Guardian.Plug.api_sign_in(build_conn(), user)
      conn = get conn, admin_post_path(conn, :new)
      assert html_response(conn, 200) =~ "title"
    end
  end

  describe "create" do

    setup do
      TestUtils.reset_all
      user = TestUtils.create_user
      conn = Guardian.Plug.api_sign_in(build_conn(), user)
      {:ok, %{conn: conn, user: user}}
    end

    @tag :success
    test "creates a new post with valid attrs", %{conn: conn} do
      post conn, admin_post_path(conn, :create), post: @valid_attrs
      PostsCache.test_callback
      assert Repo.all(Post) |> length == 1
    end

    @tag :success
    test "updates the posts cache", %{conn: conn} do
      {:ok, posts} = PostsCache.get_posts
      assert posts == []

      post conn, admin_post_path(conn, :create), post: @valid_attrs

      {:ok, posts} = PostsCache.get_posts
      assert posts |> length == 1

      {:ok, post} = PostsCache.get_post("test-post")
      assert post
    end

    @tag :success
    test "associates post with signed in user", %{conn: conn} do
      post conn, admin_post_path(conn, :create), post: @valid_attrs
      user = Repo.all(User) |> Repo.preload(:posts) |> List.first
      PostsCache.test_callback
      assert user.posts |> length == 1
    end

    @tag :success
    test "redirects to the posts index action", %{conn: conn} do
      conn = post conn, admin_post_path(conn, :create), post: @valid_attrs
      PostsCache.test_callback
      assert html_response(conn, 302)
    end

    @tag :failure
    test "renders new for a failed create", %{conn: conn} do
      conn = post conn, admin_post_path(conn, :create), post: @invalid_attrs
      PostsCache.test_callback
      assert html_response(conn, 200) =~ "title"
    end
  end
end

