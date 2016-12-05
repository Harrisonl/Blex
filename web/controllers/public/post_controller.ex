defmodule Blex.Public.PostController do
  use Blex.Web, :controller

  alias Blex.{PostsCache}

  @doc """
  Returns a list of all the posts, or a filtered list
  pased on the passed in parameters.
  """
  def index(conn, _params) do
    {:ok, posts} = PostsCache.get_posts

    #conn
    #|> put_resp_header("content-type", "text/html; charset=utf-8")
    #|> send_file(200, "priv/static/test.html")
    render(conn, "index.html", posts: posts)
  end

  @doc """
  Renders a single post, selected by the passed in slug.

  This will be constantly changing.
  """
  def show(conn, %{"slug" => slug}) do
    post = slug |> PostsCache.get_post
    case post do
      {:error, message} ->
        conn
        |> send_resp(404, message)
        |> render(Blex.ErrorView, "404.html")
      {:ok, post} ->
        conn
        |> put_resp_header("content-type", "text/html; charset=utf-8")
        |> send_file(200, "priv/static/#{slug}.html")
    end
  end


end
