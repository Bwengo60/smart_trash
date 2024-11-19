defmodule SmartTrash.Database.Schema.Roles do
  use Ecto.Schema
  import Ecto.Changeset

  @db_columns [
    :group,
    :permissions,
    :active
  ]

  schema "roles_table" do
      field :group, :string
      field :permissions, {:array, :string}, default: []
      field :active, :boolean, default: true

      timestamps()
  end

  def changeset(roles, attrs) do
    roles
    |> cast(attrs, @db_columns)
  end

end
