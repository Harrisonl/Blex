defmodule Blex.SettingsHelpers do
  @moduledoc """
  Helpers for easily accessing the blogs settings throughout the application views and tempaltes.
  """

  @doc """
  Takes in a settings field and returns the value

  ## Example
  ```elixir
  iex> setting(:blog_name)
  "Harry's Blog"
  ```
  """
  def setting(field) do
    field
    |> Blex.SettingsCache.get_setting
    |> elem(1)
  end
end
