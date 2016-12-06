defmodule Blex.SessionController do
  use Blex.Web, :controller
  alias Blex.{Authenticator, User}

  plug :scrub_params, "session" when action in ~w(create)a

  @doc """
  Renders the login page.
  """
  def new(conn, _params), do: conn |> render("new.html")

  @doc """
  Attempts to log the user in. 

  If the credentials are invalid, or the user is non-existent it will return an error and
  re-render the login screen. 

  `Authenticator.login/2` will also simulate a password check if the user isn't found in order
  to prevent brute force attacks.
  """
  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    login_result = 
      User
      |> Repo.get_by(email: email)
      |> Authenticator.check_pw(password)
      |> Authenticator.login(conn)

    case login_result do
      {:ok, conn} ->
        conn
        |> redirect(to: post_path(conn, :index))
      _ ->
        conn
        |> put_status(422)
        |> put_flash(:error, "Invalid Email/Password Combination")
        |> render("new.html")
    end
  end

  @doc """
  Signs a user out and returns them to the index.
  """
  def delete(conn, _params) do
    conn
    |> Guardian.Plug.sign_out
    |> redirect(to: post_path(conn, :index))
  end
end
