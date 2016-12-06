defmodule Blex.TestUtils do
  @moduledoc false
  alias Blex.{Repo, Post, User}
  @doc """
  Resets the database and the cache for each test
  """
  def reset_all do
    :posts_cache
    |> ConCache.ets
    |> :ets.tab2list
    |> Enum.each(fn({key, _}) -> ConCache.delete(:posts_cache, key) end)

    Repo.delete_all(Post)
    Repo.delete_all(User)
  end

  def wipe_models do
    Repo.delete_all(Post)
    Repo.delete_all(User)
  end

  def create_user do
    attrs = %{
      name: "Alice Jones",
      email: "alice@test.com",
      role: "admin",
      password: "12345678"
    }

    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert!
  end
end
