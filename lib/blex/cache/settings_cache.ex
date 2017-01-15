defmodule Blex.SettingsCache do
  use GenServer
  @moduledoc """
  This is an abstraction that handles the storing, updating and deleting of the settings cache.

  The cache uses :ets for lookups and writes and `:dets` for persistance. Because of the settings are frequently retrieved, `{:read_concurrency, true}` is set on the `:ets` table to provide faster lookup times.

  All the blogs settings are persisted via the :dets module, under the file name `:settings_cache_disk`. Since
  they will be accessed frequently, using the dets for storage ensures the lookup will be fast.

  When the genserver exits, the ets table is transferred to the backup dets table.

  The available settings are:

  * :initial_setup -> boolean
  * :comment_platform -> string
  * :blog_name -> string
  * :blog_tagline -> string
  * :header_title -> string
  * :logo -> string
  * :favicon -> string
  * :header_content -> string
  * :footer_content -> string

  The api is very simple and exposes four methods:

  `SettingsCache.get_setting(key)`
  `SettingsCache.get_settings(key)`
  `SettingsCache.update_setting(key, value)`
  `SettingsCache.update_settings(key, value)`

  For example:

  ```elixir
  iex> SettingsCache.get_setting(:blog_name)
  {:ok, "Harry's Blog"}

  iex> SettingsCache.get_settings
  {:ok, [blog_name: "Harry's Blog", blog_tagline: "Welcome"]}

  iex> SettingsCache.update_setting(:blog_name, "Glen's Blog")
  {:ok, "Glen's Blog}

  iex> SettingsCache.update_settings(%{blog_name: "Glen's Blog"})
  {:ok, [blog_name: "Glen's Blog, blog_tagline: "Welcome"...]}
  ```
  """

  # -------- PUBLIC
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Updates the given key with the passed in value.
  """
  def update_setting(key, val) do
    GenServer.call(__MODULE__, {:update, key, val})
  end

  @doc """
  Updates multiple blog settings at once. Takes in a settings map as the argument.

  Returns a list of all the blogs current settings.

  ```elixir
  iex(1)> SettingsCache.update_settings(%{blog_name: "harry's blog"})
  [blog_name: "harry's blog"]
  """
  def update_settings(settings) do
    GenServer.call(__MODULE__, {:update_many, settings})
  end

  @doc """
  Fetches the value for the given key. If the key has no associated value
  then `{:error, "Setting not found"}` is returned
  """
  def get_setting(key) do
    GenServer.call(__MODULE__, {:fetch, key})
  end

  @doc """
  Gets all of the blogs settings and converts them into a list.
  """
  def get_settings do
    {:ok, :ets.tab2list(:settings_cache)}
  end

  # -------- GENSERVER IMPLEMENTATION
  def init(_) do
    Process.flag(:trap_exit, :true)
    :ets.new(:settings_cache, [:named_table, {:read_concurrency, true}])
    load_existing_settings()
    load_defaults()
    {:ok, []}
  end

  def handle_call({:fetch, key}, _from, state) do
    case :ets.lookup(:settings_cache, key) do
      [] -> 
        {:reply, {:error, "Setting not found"}, state}
      [{_key, val} | _rest] -> 
        {:reply, {:ok, val}, state}
    end
  end

  def handle_call({:update_many, settings}, _from, state) do
    errors = 
      settings
      |> Enum.reduce(%{}, fn({key,val}, acc) ->
        key
        |> key_from_string
        |> validate_key(val)
        |> validate_value
        |> update_key 
        |> add_errors(acc)
      end)

    settings_list = :ets.tab2list(:settings_cache)

    cond do
      %{} == errors ->
        {:reply, {:ok, settings_list}, state}
      true ->
        {:reply, {:error, [{:errors, errors} | settings_list]}, state}
    end
  end

  def handle_call({:update, key, val}, _from, state) do
    update = 
      key
      |> key_from_string
      |> validate_key(val)
      |> validate_value
      |> update_key
    
    create_response(update, state)
  end

  # Used for tests
  def handle_call({:clear}, _from, state) do
    :settings_cache
    |> :ets.tab2list
    |> Enum.each(fn({key, _}) -> :ets.delete(:settings_cache, key) end)
    load_defaults()
    {:reply, {:ok}, state}
  end

  def terminate(_reason, _state) do
    :ets.to_dets(:settings_cache, :settings_cache_disk)
    :dets.close(:settings_cache_disk)
    :ok
  end

  # ------ PRIVATE
  defp load_existing_settings do
    :settings_cache_disk
    |> :dets.open_file([type: :set]) 
    |> elem(1)
    |> :dets.to_ets(:settings_cache)
  end

  defp load_defaults do
    [
      {:initial_setup, false},
      {:comment_platform, :blex},
      {:blog_name, "Blog Name"},
      {:blog_tagline, "Your Blog tagline"},
      {:header_title, "Blog title"},
      {:logo, "http://logo_url"},
      {:favicon, "http://favicon_url"},
      {:header_content, "custom code inserted before <body>"},
      {:footer_content, "custom code inserted after <body>"}
    ]
    |> Enum.each(fn({k,v}) ->
      case :ets.lookup(:settings_cache, k) do
        [] ->
          :ets.insert(:settings_cache, {k,v})
        _ ->
          nil
      end
    end)
  end

  defp update_key({false, key, reason}), do: {:error, key, reason}
  defp update_key({true, key,val}) do
    :ets.insert(:settings_cache, {key, val})
    :dets.insert(:settings_cache_disk, {key, val})
    :ok
  end

  def key_from_string(key) when is_atom(key), do: key
  def key_from_string(key), do: String.to_atom(key)

  def add_errors(:ok, acc), do: acc
  def add_errors({:error, nil, _reason}, acc), do: acc
  def add_errors({:error, key, reason}, acc), do: Map.put(acc, key, reason)

  def create_response(:ok, state), do: {:reply, :ok, state}
  def create_response({:error, key, reason}, state), do: {:reply, {:error, {key, reason}}, state}

  # Settings key validations
  defp validate_key(key, val) when key in [:initial_setup, :comment_platform, :blog_name, :blog_tagline, :header_title, :logo, :favicon, :header_content, :footer_content], do: {true, key, val}
  defp validate_key(_,_v), do: {false, nil, nil}

  # Settings value validations
  defp validate_value({true, :initial_setup = key, val}) when is_boolean(val), do: {true, key, val} 
  defp validate_value({true, :comment_platform = key, val}) when val in ["blex", "disqus"], do: {true, key, val} 
  defp validate_value({true, :blog_name = key, val}) when is_binary(val) and byte_size(val) <= 256, do: {true, key, val} 
  defp validate_value({true, :blog_tagline = key, val}) when is_binary(val) and byte_size(val) <= 256, do: {true, key, val} 
  defp validate_value({true, :header_title = key, val}) when is_binary(val) and byte_size(val) <= 256, do: {true, key, val} 
  defp validate_value({true, :logo = key, val}) when is_binary(val), do: {true, key, val} 
  defp validate_value({true, :favicon = key, val}) when is_binary(val), do: {true, key, val} 
  defp validate_value({true, :header_content = key, val}) when is_binary(val), do: {true, key, val} 
  defp validate_value({true, :footer_content = key, val}) when is_binary(val), do: {true, key, val} 
  defp validate_value({_bool, key, _val}), do: {false, key, rule_for_val(key)}

  defp rule_for_val(:initial_setup), do: "Must be true/false"
  defp rule_for_val(:comment_platform), do: "Must be either 'Blex' or 'Disqus'"
  defp rule_for_val(:blog_name), do: "Must be less than 256 characters"
  defp rule_for_val(:blog_tagline), do: "Must be less than 256 characters"
  defp rule_for_val(:header_title), do: "Must be less than 256 characters"
  defp rule_for_val(:logo), do: "Must be a valid url"
  defp rule_for_val(:favicon), do: "Must be a valid url"
  defp rule_for_val(_), do: "Invalid value supplied"
end
