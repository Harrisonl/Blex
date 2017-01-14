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

  describe "get_settings/1" do
    setup do
      on_exit fn ->
        GenServer.call(SettingsCache, {:clear})
        :dets.delete_all_objects(:settings_cache_disk)
        :dets.close(:settings_cache_disk)
        kill_proc(SettingsCache)
      end

      SettingsCache.update_setting(:blog_name, "Alice's Blog")
      :ok
    end

    @tag :success
    test "returns {:ok, settings} for a stored setting" do
      assert SettingsCache.get_settings == {:ok, 
       [favicon: "http://favicon_url", comment_platform: :blex,
        header_title: "Blog title", blog_tagline: "Your Blog tagline",
        header_content: "custom code inserted before <body>",
        logo: "http://logo_url", initial_setup: false,
        blog_name: "Alice's Blog",
        footer_content: "custom code inserted after <body>"]}
    end
  end

  describe "start_link/0" do
    setup do
      on_exit fn ->
        GenServer.call(SettingsCache, {:clear})
        :dets.delete_all_objects(:settings_cache_disk)
        :dets.close(:settings_cache_disk)
        kill_proc(SettingsCache)
      end
      :ok
    end

    @tag :success
    test "it should load the default values" do
      kill_proc(SettingsCache)
      assert :ets.info(:settings_cache)[:size] == 9
    end

    @tag :success
    test "it should not override existing values" do
      SettingsCache.update_setting(:blog_name, "Bob's Blog")
      kill_proc(SettingsCache)
      assert SettingsCache.get_setting(:blog_name) == {:ok, "Bob's Blog"}
    end
  end

  describe "update_setting/2" do
    setup do
      on_exit fn ->
        GenServer.call(SettingsCache, {:clear})
        :dets.delete_all_objects(:settings_cache_disk)
        :dets.close(:settings_cache_disk)
        kill_proc(SettingsCache)
      end
      :ok
    end

    @tag :success
    test "updates the passed in the setting with the given value" do
      kill_proc(SettingsCache)
      assert {:ok, "Blog Name"} == SettingsCache.get_setting(:blog_name)
      SettingsCache.update_setting(:blog_name, "Bob's Blog")
      assert {:ok, "Bob's Blog"} == SettingsCache.get_setting(:blog_name)
    end

    @tag :success
    test "if the key is invalid, it ignores it" do
      SettingsCache.update_setting(:blog_name_fake, "Bob's Blog")
      assert {:error, "Setting not found"} == SettingsCache.get_setting(:blog_name_fake)
    end
  end

  describe "update_settings/2" do
    setup do
      on_exit fn ->
        GenServer.call(SettingsCache, {:clear})
        :dets.delete_all_objects(:settings_cache_disk)
        :dets.close(:settings_cache_disk)
      end
      :ok
    end

    @tag :success
    test "updates the passed in the settings" do
      kill_proc(SettingsCache)
      assert {:ok, "Blog Name"} == SettingsCache.get_setting(:blog_name)
      res = SettingsCache.update_settings(%{blog_name: "Bob's Blog", header_title: "It's Great"})
      assert res == {:ok,
       [favicon: "http://favicon_url", comment_platform: :blex, header_title: "It's Great", blog_tagline: "Your Blog tagline", header_content: "custom code inserted before <body>", logo: "http://logo_url", initial_setup: false, blog_name: "Bob's Blog", footer_content: "custom code inserted after <body>"]
     }
    end

    @tag :success
    test "if the key is invalid, it ignores it" do
      SettingsCache.update_settings(%{blog_name_fake: "bob's blog"})
      assert {:error, "Setting not found"} == SettingsCache.get_setting(:blog_name_fake)
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

  def kill_proc(mod) do
    :dets.close(:settings_cache_disk)

    mod
    |> Process.whereis
    |> Process.exit(:kill)

    :timer.sleep(300)
  end

end
