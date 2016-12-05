defmodule Blex.Authenticator do
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

  @moduledoc """
  Manages the authentication side of the blog.

  Provides functionality for checking the pasword and logging in the user.
  """

  def check_pw(nil, _password), do: {:error, dummy_checkpw, nil}
  def check_pw(user, password), do: {:ok, checkpw(password, user.password_hash), user}

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
