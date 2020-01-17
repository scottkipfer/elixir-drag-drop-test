defmodule LiveViewTodos.Todos.Todo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "todos" do
    field :done, :boolean, default: false
    field :title, :string
    field :pos, :integer

    timestamps()
  end

  @doc false
  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:title, :done, :pos])
    |> validate_required([:title, :done, :pos])
  end
end
