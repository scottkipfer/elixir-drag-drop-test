defmodule LiveViewTodos.Todos do
  @moduledoc """
  The Todos context.
  """

  @topic inspect(__MODULE__)

  import Ecto.Query, warn: false
  alias LiveViewTodos.Repo

  alias LiveViewTodos.Todos.Todo

  require Logger

  def subscribe do
    Phoenix.PubSub.subscribe(LiveViewTodos.PubSub, @topic)
  end

  defp broadcast_change({:ok, result}, event) do
    Phoenix.PubSub.broadcast(LiveViewTodos.PubSub, @topic, {__MODULE__, event, result})

    {:ok, result}
  end

  @doc """
  Returns the list of todos.

  ## Examples

      iex> list_todos()
      [%Todo{}, ...]

  """
  def list_todos do
    Todo |> order_by(asc: :pos) |> Repo.all()
  end

  @doc """
  Gets a single todo.

  Raises `Ecto.NoResultsError` if the Todo does not exist.

  ## Examples

      iex> get_todo!(123)
      %Todo{}

      iex> get_todo!(456)
      ** (Ecto.NoResultsError)

  """
  def get_todo!(id), do: Repo.get!(Todo, id)

  def get_next_pos() do
    todo = Repo.one(from x in Todo, order_by: [desc: x.pos], limit: 1)
    case todo do
      nil -> 0
      todo -> todo.pos + 1
    end
  end

  def get_first_pos() do
    todo = Repo.one(from x in Todo, order_by: [asc: x.pos], limit: 1)
    case todo do
      nil -> 0
      todo -> todo.pos - 1
    end
  end

  @doc """
  Creates a todo.

  ## Examples

      iex> create_todo(%{field: value})
      {:ok, %Todo{}}

      iex> create_todo(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_todo(attrs \\ %{}) do
    attrs = Map.put_new(attrs, "pos", get_next_pos())

    %Todo{}
    |> Todo.changeset(attrs)
    |> Repo.insert()
    |> broadcast_change([:todo, :created])
  end

  @doc """
  Updates a todo.

  ## Examples

      iex> update_todo(todo, %{field: new_value})
      {:ok, %Todo{}}

      iex> update_todo(todo, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_todo(%Todo{} = todo, attrs) do
    todo
    |> Todo.changeset(attrs)
    |> Repo.update()
    |> broadcast_change([:todo, :updated])
  end

  @doc """
  Deletes a Todo.

  ## Examples

      iex> delete_todo(todo)
      {:ok, %Todo{}}

      iex> delete_todo(todo)
      {:error, %Ecto.Changeset{}}

  """
  def delete_todo(%Todo{} = todo) do
  Repo.transaction(fn ->
    Repo.delete(todo)
    from(t in Todo, where: t.pos > ^todo.pos) |> Repo.update_all(inc: [pos: -1])
  end)
    |> broadcast_change([:todo, :deleted])
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking todo changes.

  ## Examples

      iex> change_todo(todo)
      %Ecto.Changeset{source: %Todo{}}

  """
  def change_todo(%Todo{} = todo) do
    Todo.changeset(todo, %{})
  end

  def move_after(%Todo{} = startTodo, %Todo{} = endTodo) do
    Repo.transaction(fn ->
      from(t in Todo, where: t.pos > ^endTodo.pos) |> Repo.update_all(inc: [pos: 1])
      update_todo(startTodo, %{pos: endTodo.pos + 1})
      from(t in Todo, where: t.pos > ^startTodo.pos) |> Repo.update_all(inc: [pos: -1])
    end)
    |> broadcast_change([:todo, :moved])
  end

  def move_before(%Todo{} = startTodo, %Todo{} = endTodo) do
    Repo.transaction(fn ->
      from(t in Todo, where: t.pos >= ^endTodo.pos) |> Repo.update_all(inc: [pos: 1])
      update_todo(startTodo, %{pos: endTodo.pos})
      from(t in Todo, where: t.pos > ^startTodo.pos) |> Repo.update_all(inc: [pos: -1])
    end)
    |> broadcast_change([:todo, :moved])
  end

end
