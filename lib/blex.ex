defmodule Blex do
  use Application
  @moduledoc false

  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      supervisor(Blex.Repo, []),
      supervisor(Blex.Endpoint, []),
      supervisor(Blex.CacheSupervisor, [])
    ]
    opts = [strategy: :one_for_one, name: Blex.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Blex.Endpoint.config_change(changed, removed)
    :ok
  end
end
