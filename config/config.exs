# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :blex,
  ecto_repos: [Blex.Repo]

# Configures the endpoint
config :blex, Blex.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "kLHH0PEEelzrFq/nU+3PM6bceQYH0x/SMu6Qs5l7H18vxWvJhiH+nGZnaD6UTxVp",
  render_errors: [view: Blex.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Blex.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
