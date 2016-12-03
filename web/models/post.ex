defmodule Blex.Post do
  use Blex.Web, :model

  schema "posts" do
    field :title, :string
    field :subtitle, :string
    field :body, :string
    field :author, :string
    field :metadata, :string
    field :status, :string

    timestamps
  end

  @required_params ~w(title body status author)
  @optional_params ~w(subtitle metadata)

  @doc """
  Takes in a post struct and params and creates a post.

  Example

  ```elixir
  iex> post = Post.changeset(%Post{}, %{title: "Test", body: "# Markdown \n ---", status: "draft", author: "Harry"})
  #Ecto.Changeset<action: nil,
  changes: %{author: "Harry", body: "# Markdown title", status: "draft",
  title: "Test"}, errors: [], data: #Blex.Post<>, valid?: true>

  iex> Repo.insert(post)
  {:ok,
    %Blex.Post{__meta__: #Ecto.Schema.Metadata<:loaded, "posts">, author: "Harry",
    body: "# Markdown title", id: 2,
    inserted_at: #Ecto.DateTime<2016-12-03 04:50:07>, metadata: nil,
    status: "draft", subtitle: nil, title: "Test",
    updated_at: #Ecto.DateTime<2016-12-03 04:50:07>}}
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_params, @optional_params)
  end
end
