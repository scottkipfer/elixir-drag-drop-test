defmodule LiveViewTodosWeb.TodoLive do
  use Phoenix.LiveView
  require Logger

  alias LiveViewTodos.Todos
  alias LiveViewTodosWeb.TodoView

  def mount(_session, socket) do
    Todos.subscribe()

    {:ok, fetch(socket)}
  end


  def render(assigns)  do
    TodoView.render("todos.html", assigns)
  end

  def handle_event("add", %{"todo" => todo}, socket) do
    Todos.create_todo(todo)

    {:noreply, fetch(socket)}
  end

  def handle_event("toggle_done", %{"id" => id}, socket)  do
    todo = Todos.get_todo!(id)
    Todos.update_todo(todo, %{done: !todo.done})
    {:noreply, socket}
  end

  def handle_event("move_to_end", %{"value" => id}, socket) do
    todo = Todos.get_todo!(id)
    next_pos = Todos.get_next_pos()
    if todo.pos != (next_pos - 1) do
      Todos.update_todo(todo, %{pos: next_pos})
    end
    {:noreply, socket}
  end

  def handle_event("move_to_start", %{"value" => id}, socket) do
    todo = Todos.get_todo!(id)
    first_pos = Todos.get_first_pos()
    if todo.pos != (first_pos + 1) do
      Todos.update_todo(todo, %{pos: first_pos})
    end
    {:noreply, socket}
  end

  def handle_event("move_before", %{"startId" => startId, "endId" => endId}, socket) do
    startTodo = Todos.get_todo!(startId)
    endTodo = Todos.get_todo!(endId)
    Todos.move_before(startTodo, endTodo)

    {:noreply, socket}
  end

  def handle_event("move_after", %{"startId" => startId, "endId" => endId}, socket) do
    startTodo = Todos.get_todo!(startId)
    endTodo = Todos.get_todo!(endId)
    Todos.move_after(startTodo, endTodo)

    {:noreply, socket}
  end

  def handle_event("delete_todo", %{"id" => id}, socket) do
    todo = Todos.get_todo!(id)
    Todos.delete_todo(todo)
    {:noreply, socket}

    {:noreply, socket}
  end

  def handle_info({Todos, [:todo | _], _}, socket) do
    {:noreply, fetch(socket)}
  end

  defp fetch(socket) do
    assign(socket, todos: Todos.list_todos())
  end

end
