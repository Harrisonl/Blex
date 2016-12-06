defmodule Blex.PostsCacheTest do
  use ExUnit.Case, async: false
  import Ecto.Query
  alias Blex.{Post, Repo, PostsCache, TestUtils}

  @valid_attrs %{title: "Test Post 3", body: "# Markdown", status: "draft", author: "Alice", slug: "test-post"}
  @invalid_attrs %{}

  setup_all do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Repo, { :shared, self() })
    :ok
  end

  describe "get_post/1" do
    setup do
      TestUtils.reset_all
      post = Post.changeset(%Post{}, @valid_attrs) |> Repo.insert!
      {:ok, %{post: post}}
    end

    @tag :success
    test "returns {:ok, post} for a stored post", %{post: post} do
      ConCache.insert_new(:posts_cache, post.slug, post)
      assert {:ok, _post} = PostsCache.get_post(post.slug)
    end

    @tag :success
    test "returns {:ok, post} for a that is not already in the cache", %{post: post} do
      assert {:ok, _post} = PostsCache.get_post(post.slug)
    end

    @tag :failure
    test "returns {:error, message} for a post that doesn't exist" do
      assert {:error, "Post not found"} = PostsCache.get_post("fake-post")
    end
  end

  describe "get_posts/0" do
    setup do
      Blex.TestUtils.reset_all
      post = Post.changeset(%Post{}, @valid_attrs) |> Repo.insert!
      Post.changeset(%Post{}, Map.put(@valid_attrs, :slug, "test-two")) |> Repo.insert!
      {:ok, %{post: post}}
    end

    @tag :success
    test "returns {:ok, posts} for a stored posts" do
      Post
      |> Repo.all
      |> Enum.each(fn(p) -> ConCache.insert_new(:posts_cache, p.slug, p) end)
      {:ok, posts} = PostsCache.get_posts
      assert 2 == posts |> length
      assert posts == Repo.all((from p in Post, select: [:title, :slug, :subtitle, :author, :inserted_at, :body]))
    end

    @tag :success
    test "returns {:ok, posts} for posts not in the cache" do
      {:ok, posts} = PostsCache.get_posts
      assert 2 == posts |> length
    end
  end

  describe "update_posts/0" do
    setup do
      Blex.TestUtils.reset_all
      post = Post.changeset(%Post{}, @valid_attrs) |> Repo.insert!
      {:ok, %{post: post}}
    end

    @tag :success
    test "gets all the posts from the database and replaces them in the cache", %{post: post} do
      changed_post = Post.changeset(post, %{title: "Changed"}) |> Repo.update!
      PostsCache.update_posts
      GenServer.call(PostsCache, {:test_callback})
      assert {:ok, ^changed_post} = PostsCache.get_post(post.slug)
    end

    @tag :success
    test "Doesn't change existing posts in the cache", %{post: post} do
      Post.changeset(post, %{slug: "changed-slug"}) |> Repo.update!
      Post.changeset(%Post{}, @valid_attrs) |> Repo.insert!
      PostsCache.update_posts
      PostsCache.test_callback
      {:ok, posts} = PostsCache.get_posts
      assert  posts |> length == 2
    end

  end
end
