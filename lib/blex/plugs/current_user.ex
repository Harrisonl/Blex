defmodule Blex.CurrentUser do

  def init(opts), do: opts

  def call(conn, _opts) do
    user = conn |> Guardian.Plug.current_resource
    Plug.Conn.assign(conn, :current_user, user)
  end

end
