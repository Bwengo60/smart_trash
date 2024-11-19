defmodule SmartTrash.Database.Schema.Trash do
  use Ecto.Schema
  import Ecto.Changeset
  alias SmartTrash.Accounts.User

  @db_columns [
    :trash_number,
    :trash_levels,
    :active,
    :collected
  ]

  schema "trash_table" do
    field :trash_number, :string
    field :trash_levels, :integer
    field :active, :boolean
    field :collected, :boolean, default: true
    has_one :user, User, foreign_key: :users_table

    timestamps()
  end

  def changeset(trash, attrs) do
    trash
    |> cast(attrs, @db_columns)
  end

end
