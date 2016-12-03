defmodule Blex.PostControllerTest do
  use Blex.ConnCase

  alias Blex.Post
  @valid_attrs %{title: "Test Post", body: "# Markdown", status: "draft", author: "Alice"}
  @invalid_attrs %{}

  @tag :index
  test "lists all entries on index", %{conn: conn} do
    conn = get conn, post_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing posts"
  end

  @tag :show
  test "shows chosen resource", %{conn: conn} do
    post = %Post{} |> Post.changeset(@valid_attrs) |> Repo.insert!
    conn = get conn, post_path(conn, :show, post)
    assert html_response(conn, 200) =~ "Test Post"
  end

  @tag :show
  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, post_path(conn, :show, -1)
    end
  end
end
