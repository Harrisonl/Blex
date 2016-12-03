defmodule Blex.Router do
  use Blex.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Blex.Public do
    pipe_through :browser

    resources "/posts", PostController, only: [:show, :index]
    get "/", PostController, :index
  end

  scope "/", Blex do
    pipe_through :browser

    scope "/admin", Admin, as: :admin do
      resources "/posts", PostController
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", Blex do
  #   pipe_through :api
  # end
end
