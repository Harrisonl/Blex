defmodule Blex.Admin.SettingsController do
  use Blex.Web, :controller
  alias Blex.{SettingsCache}

  @doc """
  Returns all the current settings for the blog
  """
  def index(conn, _params) do
    {:ok, settings} = SettingsCache.get_settings
    render(conn, "index.html", settings: settings)
  end

  @doc """
  Updates the passed in settings and returns a list of the settings
  """
  def update(conn, %{"settings" => settings_params}) do
    {:ok, settings} = SettingsCache.update_settings(settings_params)
    render(conn, "index.html", settings: settings)
  end
end
