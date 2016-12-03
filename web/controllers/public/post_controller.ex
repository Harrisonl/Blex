defmodule Blex.Public.PostController do
  use Blex.Web, :controller

  alias Blex.Post

  @doc """
  Returns a list of all the posts, or a filtered list
  pased on the passed in parameters.
  """
  def index(conn, _params) do
    posts = Repo.all(Post)
    render(conn, "index.html", posts: posts)
  end

  @doc """
  Renders a single post, selected by the passed in slug.

  This will be constantly changing.
  """
  def show(conn, %{"id" => id}) do
    post = Repo.get!(Post, id)
    render(conn, "show.html", post: post)
  end

end
