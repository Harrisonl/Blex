defmodule Blex.PageController do
  use Blex.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
