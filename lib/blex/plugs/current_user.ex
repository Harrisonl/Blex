defmodule Blex.CurrentUser do

  @moduledoc """
  This plug loads the current user into the plug giving us access
  to the current_user throughout the application.
  """

  @doc """
  As per the plug behavior. Nothing is done to the passed in options.
  """
  def init(opts), do: opts

  @doc """
  Asks guardian for the current resource and assigns it to the
  current_user key on the connection.
  """
  def call(conn, _opts) do
    user = conn |> Guardian.Plug.current_resource
    Plug.Conn.assign(conn, :current_user, user)
  end

end
