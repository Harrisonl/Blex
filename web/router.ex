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
    pipe_through [:browser, :session]

    scope "/admin", Admin, as: :admin do
      resources "/posts", PostController
      resources "/users", UserController
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", Blex do
  #   pipe_through :api
  # end
end
