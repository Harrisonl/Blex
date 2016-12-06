defmodule Blex.Admin.PostController do
  use Blex.Web, :controller

  alias Blex.{Post, PostsCache, Repo}
  @doc """
  Creates a new post changeset and renders it for the html
  view.
  """
  def new(conn, _params) do
    changeset = Post.changeset(%Post{})
    render(conn, "new.html", changeset: changeset)
  end
  
  @doc """
  Renders all the posts for the admin to view. Note it doesn't load them
  from the cache, but rather from the DB.
  """
  def index(conn, _params) do
    posts = Repo.all(Post)
    render(conn, "index.html", posts: posts)
  end

  @doc """
  Creates a new post resource.

  This will update the posts cache regardless of whether or not the insert succeeded.
  """
  def create(conn, %{"post" => post_params}) do
    post_struct = conn.assigns[:current_user] |> build_assoc(:posts)
    post = 
      post_struct
      |> Post.changeset(post_params)
      |> Repo.insert

    PostsCache.update_posts
    render_insert(post, conn, admin_post_path(conn, :index))
  end
end
