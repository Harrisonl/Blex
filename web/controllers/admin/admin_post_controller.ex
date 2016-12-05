defmodule Blex.Admin.PostController do
  use Blex.Web, :controller

  alias Blex.{Post, PostsCache}
  @doc """
  Creates a new post changeset and renders it for the html
  view.
  """
  def new(conn, _params) do
    changeset = Post.changeset(%Post{})
    render(conn, "new.html", changeset: changeset)
  end

  @doc """
  Creates a new post resource.

  This will update the posts cache regardless of whether or not the insert succeeded.

  TODO: If the insert is successful, the connection is redirect to the posts index.
  This needs to be changed obviously to the admin section.
  """
  def create(conn, %{"post" => post_params}) do
    post_struct = conn.assigns[:current_user] |> build_assoc(:posts)
    post = 
      post_struct
      |> Post.changeset(post_params)
      |> Repo.insert

    PostsCache.update_posts
    render_insert(post, conn, post_path(conn, :index))
  end
end
