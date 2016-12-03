defmodule Blex.PostTest do
  use Blex.ModelCase

  alias Blex.Post

  @valid_attrs %{title: "Test Post", body: "# Markdown", status: "draft", author: "Alice", slug: "test-post"}
  @invalid_attrs %{}

  @tag :changeset
  test "changeset with valid attrs" do
    changeset = Post.changeset(%Post{}, @valid_attrs)
    assert changeset.valid?
  end

  @tag :changeset
  test "changeset with invalid attrs" do
    changeset = Post.changeset(%Post{}, @invalid_attrs)
    refute changeset.valid?
  end

  @tag :changeset
  test "changeset with duplicate slug" do
    Post.changeset(%Post{}, @valid_attrs) |> Repo.insert
    assert {:error, _changeset } = Post.changeset(%Post{}, @valid_attrs) |> Repo.insert
  end

  @tag :changeset
  test "changeset with valid markdown creates valid html" do
    changeset = Post.changeset(%Post{}, @valid_attrs)
    assert changeset.changes.body_html == "<h1>Markdown</h1>\n"
  end
end
