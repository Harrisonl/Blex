#!/bin/bash -e
echo "Fetching Dependencies"
mix deps.get
echo "Creating Database: (User/Password = postgres)"
mix ecto.create
echo "Migrating Database"
mix ecto.migrate
echo "Running Test"
mix test
echo "Seeding database"
mix run priv/repo/seeds.exs
