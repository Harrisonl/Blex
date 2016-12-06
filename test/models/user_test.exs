defmodule Blex.UserTest do
  use Blex.ModelCase

  alias Blex.User

  @valid_attrs %{bio: "some content", email: "some content", github: "some content", name: "some content", role: "some content", twitter: "some content"}
  @invalid_attrs %{}

  @registration_valid_attrs %{bio: "some content", email: "some content", github: "some content", name: "some content", role: "some content", twitter: "some content", password: "12345678"}
  @registration_invalid_attrs %{bio: "some content", email: "some content", github: "some content", name: "some content", role: "some content", twitter: "some content", password: "123458"}

  @tag :success
  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  @tag :failure
  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end

  @tag :success
  test "registration changeset will valid attrs" do
    changeset = User.registration_chanageset(%User{}, @registration_valid_attrs)
    assert changeset.valid?
  end

  @tag :failure
  test "registration changeset with invalid password" do
    changeset = User.registration_chanageset(%User{}, @registration_invalid_attrs)
    refute changeset.valid?
  end
end
