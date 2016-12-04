defmodule Blex.TestUtils do
  @moduledoc false
  alias Blex.{Repo, Post}
  @doc """
  Resets the database and the cache for each test
  """
  def reset_all do
    :posts_cache
    |> ConCache.ets
    |> :ets.tab2list
    |> Enum.each(fn({key, _}) -> ConCache.delete(:posts_cache, key) end)

    Repo.delete_all(Post)
  end
end
