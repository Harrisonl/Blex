defmodule Blex.PostsCache do
  use GenServer
  import Ecto.Query

  alias Blex.Repo
  alias Blex.Post

  @moduledoc """
  This is an abstraction that handles the storing, updating and deleting of the posts cache.

  The cache stores all the blogs posts inorder to provide faster rendering as it is very rarely
  going to change.

  Items are stored in the cache for a default of 30 days and that is refreshed everytime the post
  is updated. Every time a post is updated, either `update_post/1` or `update_posts/0` should be called.

  `get_post/1` and `get_posts/0` will automatically retrieve the values if they aren't already in the cache and should be
  called at initialization.
  """

  # ------ PUBLIC
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init do
    get_posts
    {:ok, []}
  end

  @doc """
  Takes in a slug and retrieves the associated post from the posts cache.

  If the post doesn't exist in the cache, then it will be retrieved from the 
  database and added to the cache.

  ```elixir
  iex> PostsCache.get_post("test-post")
  %Post{title: "Test post"....}
  ```
  """
  def get_post(slug) do
    GenServer.call(__MODULE__, {:get_post, slug})
  end

  @doc """
  Same as `get_post/1` but returns all of the posts in the cache.

  If the post doesn't exist in the cache, then it will be retrieved from the 
  database and added to the cache.

  ```elixir
  iex> PostsCache.get_posts
  [
    %Post{title: "Test post"....},
    %Post{title: "Second post"....},
    %Post{title: "Third post"....},
    %Post{title: "Fourth post"....}
  ]
  ```
  """
  def get_posts do
    GenServer.call(__MODULE__, {:get_posts})
  end

  @doc """
  Updates the entire posts_cache. 

  This includes adding a smaller version of each post to the :posts key (in order for the index view)
  and each full post to their respective slug keys.
  """
  def update_posts do
    GenServer.cast(__MODULE__, {:update_posts})
  end

  # ------ GENSERVER IMP
  @doc """
  Used to ensure that a cast succeeds in the test cases.
  """
  def handle_call({:test_callback}, _, state) do
    {:reply, {:ok}, state}
  end

  def handle_call({:get_posts},_from, state) do
    posts = get_or_store_posts
    {:reply, {:ok, posts}, state}
  end

  def handle_call({:get_post, slug},_from, _state) do
    slug
    |> get_or_store_post
    |> create_response
  end

  def handle_cast({:update_posts}, state) do
    Post
    |> Repo.all
    |> Enum.each(fn(p) ->
      ConCache.update(:posts_cache, p.slug, fn(_old_val) -> {:ok, p} end)
    end)

    ConCache.update(:posts_cache, :posts, fn(_old) -> {:ok, Repo.all(posts_for_index)} end)
    {:noreply, state}
  end

  # ------ PRIVATE
  defp get_or_store_post(slug) do 
    ConCache.get_or_store(:posts_cache, slug, fn() -> Repo.get_by(Post, slug: slug) end)
  end

  defp get_or_store_posts do 
    ConCache.get_or_store(:posts_cache, :posts, fn() -> Repo.all(posts_for_index) end)
  end

  defp posts_for_index do
    (from p in Post, select: [:title, :slug, :subtitle, :author, :inserted_at, :body])
  end

  defp create_response(nil), do: {:reply, {:error, "Post not found"}, []}
  defp create_response(post), do: {:reply, {:ok, post}, []}

end
