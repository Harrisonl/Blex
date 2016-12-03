defmodule Blex.Admin.PostController do
  use Blex.Web, :controller

  alias Blex.Post
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

  TODO: If the insert is successful, the connection is redirect to the posts index.
  This needs to be changed obviously to the admin section.
  """
  def create(conn, %{"post" => post_params}) do
     %Post{}
     |> Post.changeset(post_params)
     |> Repo.insert
     |> render_insert(conn, post_path(conn, :index))
  end
end
