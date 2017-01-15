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

  def edit(conn, _params) do
    {:ok, settings} = SettingsCache.get_settings
    render(conn, "edit.html", settings: settings)
  end

  @doc """
  Updates the passed in settings and returns a list of the settings
  """
  def update(conn, %{"settings" => settings_params}) do
    case SettingsCache.update_settings(settings_params) do
      {:ok, settings} ->
        render(conn, "index.html", settings: settings)
      {:error, settings} ->
        render(conn, "edit.html", settings: settings)
    end
  end
end
