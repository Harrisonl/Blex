defmodule Blex.SettingsCacheTest do
  use ExUnit.Case, async: false
  alias Blex.{SettingsCache}

  setup_all do
    reset_cache()
    on_exit fn ->
      :dets.delete_all_objects(:settings_cache_disk)
      :dets.close(:settings_cache_disk)
    end
    :ok
  end

  describe "validations" do
    test "should have all the errors along with settings" do
      reset_cache()
      assert SettingsCache.update_settings(%{"blog_name" => 123, "initial_setup" => 123}) == {:ok, [{:favicon, "http://favicon_url"}, {:comment_platform, :blex}, {:header_title, "Blog title"}, {:blog_tagline, "Your Blog tagline"}, {:header_content, "custom code inserted before <body>"}, {:logo, "http://logo_url"}, {:initial_setup, false}, {:blog_name, "Blog Name"}, {:footer_content, "custom code inserted after <body>"}, [initial_setup: "Must be true/false", blog_name: "Must be less than 256 characters"]]}
    end

    test "should update initial_setup" do
      assert :ok == SettingsCache.update_setting("initial_setup", true)
    end

    test "should not update initial_setup" do
      assert {:error, {:initial_setup, _reason}} = SettingsCache.update_setting("initial_setup", 123)
    end

    test "should update comment_platform" do
      assert :ok == SettingsCache.update_setting("comment_platform", "blex")
    end

    test "should not update comment_platform" do
      assert {:error, {:comment_platform, _reason}} = SettingsCache.update_setting("comment_platform", 123)
    end

    test "should update blog_name" do
      assert :ok == SettingsCache.update_setting("blog_name", "test")
    end

    test "should not update blog_name" do
      assert {:error, {:blog_name, _reason}} = SettingsCache.update_setting("blog_name", 123)
    end

    test "should update blog_tagline" do
      assert :ok == SettingsCache.update_setting("blog_tagline", "test")
    end

    test "should not update blog_tagline" do
      assert {:error, {:blog_tagline, _reason}} = SettingsCache.update_setting("blog_tagline", 123)
    end

    test "should update header_title" do
      assert :ok == SettingsCache.update_setting("header_title", "test")
    end

    test "should not update header_title" do
      assert {:error, {:header_title, _reason}} = SettingsCache.update_setting("header_title", 123)
    end

    test "should update logo" do
      assert :ok == SettingsCache.update_setting("logo", "test")
    end

    test "should not update logo" do
      assert {:error, {:logo, _reason}} = SettingsCache.update_setting("logo", 123)
    end

    test "should update favicon" do
      assert :ok == SettingsCache.update_setting("favicon", "test")
    end

    test "should not update favicon" do
      assert {:error, {:favicon, _reason}} = SettingsCache.update_setting("favicon", 123)
    end

    test "should update header_content" do
      assert :ok == SettingsCache.update_setting("header_content", "test")
    end

    test "should not update header_content" do
      assert {:error, {:header_content, _reason}} = SettingsCache.update_setting("header_content", 123)
    end

    test "should update footer_content" do
      assert :ok == SettingsCache.update_setting("footer_content", "test")
    end

    test "should not update footer_content" do
      assert {:error, {:footer_content, _reason}} = SettingsCache.update_setting("footer_content", 123)
    end
  end

  describe "get_setting/1" do
    setup do
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

    @tag :success
    test "returns {:ok, settings} for a stored setting" do
      reset_cache()
      assert SettingsCache.get_settings == {:ok, 
       [favicon: "http://favicon_url", comment_platform: :blex,
        header_title: "Blog title", blog_tagline: "Your Blog tagline",
        header_content: "custom code inserted before <body>",
        logo: "http://logo_url", initial_setup: false,
        blog_name: "Blog Name",
        footer_content: "custom code inserted after <body>"]}
    end
  end

  describe "start_link/0" do
    setup do
      on_exit fn ->
        reset_cache()
      end
      :ok
    end

    @tag :success
    test "it should load the default values" do
        reset_cache()
      assert :ets.info(:settings_cache)[:size] == 9
    end

    @tag :success
    test "it should not override existing values" do
      SettingsCache.update_setting(:blog_name, "Bob's Blog")
      assert SettingsCache.get_setting(:blog_name) == {:ok, "Bob's Blog"}
    end
  end

  describe "update_setting/2" do
    setup do
      reset_cache()
      :ok
    end

    @tag :success
    test "updates the passed in the setting with the given value" do
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
    @tag :success
    test "updates the passed in the settings" do
      reset_cache()
      assert {:ok, "Blog Name"} == SettingsCache.get_setting(:blog_name)
      res = SettingsCache.update_settings(%{blog_name: "Bob's Blog", header_title: "It's Great"})
      assert res == {:ok, [{:favicon, "http://favicon_url"}, {:comment_platform, :blex}, {:header_title, "It's Great"}, {:blog_tagline, "Your Blog tagline"}, {:header_content, "custom code inserted before <body>"}, {:logo, "http://logo_url"}, {:initial_setup, false}, {:blog_name, "Bob's Blog"}, {:footer_content, "custom code inserted after <body>"}, []]}
    end

    @tag :success
    test "if the key is invalid, it ignores it" do
      SettingsCache.update_settings(%{blog_name_fake: "bob's blog"})
      assert {:error, "Setting not found"} == SettingsCache.get_setting(:blog_name_fake)
    end
  end

  describe "on exit" do
    test "saves the ets table to the backup dets table" do
      SettingsCache.update_setting(:blog_name, "Bob's Blog")
      Process.whereis(SettingsCache)
      |> Process.exit(:kill)
      name = :dets.open_file(:settings_cache_disk) |> elem(1) |> :dets.lookup(:blog_name)
      assert [blog_name: "Bob's Blog"] == name
    end
  end

  def reset_cache do
    GenServer.call(SettingsCache, {:clear})
  end
end
