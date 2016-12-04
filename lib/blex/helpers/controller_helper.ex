defmodule Blex.ControllerHelper do
  import Phoenix.Controller

  @moduledoc """
  Provides a set of helpers and abstractions for creating clean controllers.
  """

  @doc """
  Handles the response of a successful or unsuccessful resource
  insertion.

  If the model fails validation, it is redirected to it's new page.

  Otherwise, if it is successfully inserted, the connection is 
  redirected back to the given path.
  """
  def render_insert({:error, changeset}, conn, _action) do
    conn
    |> render("new.html", changeset: changeset)
  end

  def render_insert({:ok, _resource}, conn, path) do
    conn
    |> put_flash(:info, "Successfully created.")
    |> redirect(to: path)
  end


  def render_get({:error, message}, conn, path) do
    conn
    |> put_flash(:error, message)
    |> render(Blex.ErrorView, "404.html", resource: nil)
  end

  def render_get({:ok, resource}, conn, path) do
    conn
    |> render("show.html", resource: resource)
  end
end
