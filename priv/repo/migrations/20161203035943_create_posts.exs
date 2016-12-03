defmodule Blex.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :string
      add :subtitle, :string
      add :body, :string
      add :author, :string
      add :metadata, :string
      add :status, :string

      timestamps
    end
  end
end
