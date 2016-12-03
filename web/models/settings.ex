defmodule Blex.Settings do
  use Blex.Web, :model
  @moduledoc false

  schema "settings" do
    field :initial_setup,    :boolean, default: false
    field :comment_platform, :string,  default: "blex"
    field :blog_name,        :string
    field :blog_tagline,     :string
    field :header_title,     :string
    field :logo,             :string
    field :favicon,          :string
    field :header_content,   :string
    field :footer_content,   :string
  end
end
