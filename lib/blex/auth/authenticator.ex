defmodule Blex.Authenticator do
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

  @moduledoc """
  Manages the authentication side of the blog.

  Provides functionality for checking the pasword and logging in the user.
  """

  @doc """
  Checks the given user's password hash against the hashed version of the 
  password entered for login.

  If the user is nil (e.g. not found) it will simulate a password check in order
  to prevent bruteforce attacks.
  """
  def check_pw(nil, _password), do: {:error, dummy_checkpw, nil}
  def check_pw(user, password), do: {:ok, checkpw(password, user.password_hash), user}

  @doc """
  If the user's password is valid, it will log the user in.

  Takes in a tuple from the result of `check_pw/2`
  """
  def login({:ok, true, user}, conn), do: {:ok, do_login(conn, user)}
  def login({:ok, false, _user}, _conn), do: {:error, :unauthorized}
  def login({:error, _, _user}, _conn) do 
    dummy_checkpw
    {:error, :not_found}
  end


  defp do_login(conn, user) do
    conn
    |> Guardian.Plug.sign_in(user)
  end

end
