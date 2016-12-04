defmodule Blex.Repo.Migrations.AddFieldsPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :slug, :string
      add :body_html, :text
    end

    create unique_index(:posts, [:slug])
  end
end
