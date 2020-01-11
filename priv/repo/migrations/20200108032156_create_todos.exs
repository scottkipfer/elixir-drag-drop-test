defmodule LiveViewTodos.Repo.Migrations.CreateTodos do
  use Ecto.Migration

  def change do
    create table(:todos) do
      add :title, :string
      add :done, :boolean, default: false, null: false
      add :pos, :float, null: false

      timestamps()
    end

  end
end
