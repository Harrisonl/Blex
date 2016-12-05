defmodule Blex.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :name, :string
      add :password_hash, :string
      add :role, :string
      add :bio, :text
      add :github, :string
      add :twitter, :string

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
