defmodule Blex.User do
  use Blex.Web, :model

  schema "users" do
    field :email, :string
    field :name, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :role, :string
    field :bio, :string
    field :github, :string
    field :twitter, :string

    has_many :posts, Blex.Post

    timestamps()
  end

  @required_fields ~w(email name role)a
  @optional_fields ~w(bio github twitter)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  @doc """
  Builds a new user for the struct and params provided.

  The password gets validated to be 8-characters long minimum. 

  The password is then hashed and stored under password_hash
  """
  def registration_chanageset(struct, params) do
    struct
    |> changeset(params)
    |> cast(params, ~w(password)a, [])
    |> validate_length(:password, min: 8, max: 100)
    |> hash_password
  end

  defp hash_password(changeset=%Ecto.Changeset{valid?: true, changes: %{password: password}}) do
    changeset
    |> put_change(:password_hash, Comeonin.Bcrypt.hashpwsalt(password))
  end
  defp hash_password(changeset), do: changeset
end
