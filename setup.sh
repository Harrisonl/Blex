#!/bin/bash -e
echo "###################\nFetching Dependencies\n###################"
mix deps.get
echo "###################\nCreating Database: User/Pw = postgres\n###################"
mix ecto.create
echo "###################\nMigrating Database\n###################"
mix ecto.migrate
echo "###################\nRunning Tests\n###################"
mix test
echo "###################\nSeeding tests\n###################"
mix test
mix run priv/repo/seeds.exs
