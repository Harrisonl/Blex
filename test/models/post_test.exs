defmodule Blex.PostTest do
  use Blex.ModelCase

  alias Blex.Post

  @valid_attrs %{title: "Test Post", body: "# Markdown", status: "draft", author: "Alice"}
  @invalid_attrs %{}

  test "changeset with valid attrs" do
    changeset = Post.changeset(%Post{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attrs" do
    changeset = Post.changeset(%Post{}, @invalid_attrs)
    refute changeset.valid?
  end
end
