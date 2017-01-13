defmodule Blex.SettingsCacheTest do
  use ExUnit.Case, async: false
  alias Blex.{SettingsCache}

  setup_all do
    :ok
  end

  describe "get_setting/1" do
    setup do
      on_exit fn ->
        GenServer.call(SettingsCache, {:clear})
        :dets.delete_all_objects(:settings_cache_disk)
        :dets.close(:settings_cache_disk)
      end
      SettingsCache.update_setting(:blog_name, "Alice's Blog")
      :ok
    end

    @tag :success
    test "returns {:ok, setting} for a stored setting" do
      assert {:ok, _setting} = SettingsCache.get_setting(:blog_name)
    end

    @tag :failure
    test "returns {:error, message} for a setting that doesn't exist" do
      assert {:error, "Setting not found"} = SettingsCache.get_setting("fake-setting")
    end
  end

  describe "start_link/0" do
    setup do
      on_exit fn ->
        GenServer.call(SettingsCache, {:clear})
        :dets.delete_all_objects(:settings_cache_disk)
        :dets.close(:settings_cache_disk)
      end
      :ok
    end

    @tag :success
    test "it should load the default values" do
      Process.whereis(SettingsCache)
      |> Process.exit(:kill)
      :timer.sleep(500)
      assert :ets.info(:settings_cache)[:size] == 9
    end

    @tag :success
    test "it should not override existing values" do
      SettingsCache.update_setting(:blog_name, "Bob's Blog")
      Process.whereis(SettingsCache)
      |> Process.exit(:kill)
      :timer.sleep(500)
      assert SettingsCache.get_setting(:blog_name) == {:ok, "Bob's Blog"}
    end
  end

  describe "update_setting/2" do
    setup do
      on_exit fn ->
        GenServer.call(SettingsCache, {:clear})
        :dets.delete_all_objects(:settings_cache_disk)
        :dets.close(:settings_cache_disk)
      end
      :ok
    end

    @tag :success
    test "updates the passed in the setting with the given value" do
      Process.whereis(SettingsCache)
      |> Process.exit(:kill)
      :timer.sleep(500)
      assert {:ok, "Blog Name"} == SettingsCache.get_setting(:blog_name)
      SettingsCache.update_setting(:blog_name, "Bob's Blog")
      assert {:ok, "Bob's Blog"} == SettingsCache.get_setting(:blog_name)
    end

    @tag :success
    test "if the key doesn't exist, it gracefully inserts the value" do
      SettingsCache.update_setting(:blog_name_fake, "Bob's Blog")
      assert {:ok, "Bob's Blog"} == SettingsCache.get_setting(:blog_name_fake)
    end
  end

  describe "on exit" do
    setup do
      on_exit fn ->
        GenServer.call(SettingsCache, {:clear})
        :dets.delete_all_objects(:settings_cache_disk)
        :dets.close(:settings_cache_disk)
      end
      :ok
    end
    test "saves the ets table to the backup dets table" do
      SettingsCache.update_setting(:blog_name, "Bob's Blog")
      Process.whereis(SettingsCache)
      |> Process.exit(:kill)
      name = :dets.open_file(:settings_cache_disk) |> elem(1) |> :dets.lookup(:blog_name)
      assert [blog_name: "Bob's Blog"] == name
    end
  end
end
