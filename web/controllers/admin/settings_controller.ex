defmodule Blex.Admin.SettingsController do
  use Blex.Web, :controller
  alias Blex.{SettingsCache}

  def index(conn, _params) do
    settings = :ets.tab2list(:settings_cache)
    render(conn, "index.html", settings: settings)
  end

  def update(conn, %{"settings" => settings_params}) do
    {:ok, settings} = SettingsCache.update_settings(settings_params)
    render(conn, "index.html", settings: settings)
  end
end
