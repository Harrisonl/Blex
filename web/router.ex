defmodule Blex.Router do
  use Blex.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :session do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
    plug Blex.CurrentUser
  end

  pipeline :admin do
    plug Guardian.Plug.EnsureAuthenticated, handler: Blex.SessionController
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Blex.Public do
    pipe_through [:browser, :session]

    get "/posts", PostController, :index
    get "/posts/:slug", PostController, :show
    get "/", PostController, :index
  end

  scope "/", Blex do
    pipe_through [:browser, :session]

    get "/login", SessionController, :new
    get "/signout", SessionController, :delete, as: :signout_session
    post "/login", SessionController, :create
  end

  scope "/", Blex do
    pipe_through [:browser, :session, :admin]

    scope "/admin", Admin, as: :admin do
      # ---- POSTS
      resources "/posts", PostController
      
      # ---- USERS
      resources "/users", UserController

      # ---- SETTINGS
      get "/settings", SettingsController, :index
      get "/settings/edit", SettingsController, :edit
      put "/settings", SettingsController, :update
    end
  end
end
