defmodule Blex.Repo.Migrations.CreateSettings do
  use Ecto.Migration

  def change do
    create table(:settings) do
      add :comment_platform, :string, default: "blex"
      add :blog_name, :string
      add :blog_tagline, :string
      add :header_title, :string
      add :logo, :string
      add :favicon, :string
      add :header_content, :string
      add :footer_content, :string
      add :initial_setup, :boolean, default: false

      timestamps
    end
  end
end
