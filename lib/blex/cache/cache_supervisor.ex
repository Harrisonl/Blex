defmodule Blex.CacheSupervisor do
  use Supervisor

  @moduledoc """
  Supervisor which monitors the posts and settings cache.

  Items are held for a month (unless updated prior).

  On restart, the cache is updated with the approriate items.
  """

  def start_link do
    Supervisor.start_link(__MODULE__,[], name: __MODULE__)
  end

  def init([]) do
    children = [
      worker(ConCache, [[ttl: :timer.hours(720), ttl_check: :timer.hours(1)], [name: :posts_cache]], id: :posts_cache),
      worker(ConCache, [[ttl: :timer.hours(720), ttl_check: :timer.hours(1)], [name: :settings_cache]], id: :settings_cache),

      worker(Blex.PostsCache, [])
    ]

    supervise(children, strategy: :one_for_one)
  end

end
