defmodule Blex.SessionController do
  use Blex.Web, :controller
  alias Blex.{Authenticator, User}

  plug :scrub_params, "session" when action in ~w(create)a

  def new(conn, _params) do
    conn
    |> render("new.html")
  end

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
        |> put_flash(:error, "Invalid Email/Password Combination")
        |> render("new.html")
    end
  end

  def delete(conn, _params) do
    conn
    |> Guardian.Plug.sign_out
    |> redirect(to: post_path(conn, :index))
  end
end
