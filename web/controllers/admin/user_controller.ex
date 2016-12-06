defmodule Blex.Admin.UserController do
  use Blex.Web, :controller
  alias Blex.{Repo, User}

  plug :scrub_params, "user" when action in [:create]

  @doc """
  Renders the new user screen. Only accessible by admins
  """
  def new(conn, _params) do
    changeset = User.changeset(%User{})
    conn
    |> render("new.html", changeset: changeset)
  end

  @doc """
  Creates a new user for the passed in params.
  """
  def create(conn, %{"user" => user_params}) do
    %User{} 
    |> User.registration_chanageset(user_params)
    |> Repo.insert
    |> render_insert(conn, admin_user_path(conn, :index))
  end

  @doc """
  Displays all the current users.
  """
  def index(conn, _params) do
    users = Repo.all(User)

    conn
    |> render("index.html", users: users)
  end
end
