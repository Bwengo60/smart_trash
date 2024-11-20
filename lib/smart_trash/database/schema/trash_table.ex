defmodule SmartTrash.Database.Schema.Trash do
  use Ecto.Schema
  import Ecto.Changeset
  alias SmartTrash.Accounts.User

  @db_columns [
    :trash_number,
    :trash_levels,
    :active,
    :collected,
    :user_id
  ]

  schema "trash_table" do
    field :trash_code, :string
    field :trash_levels, :integer, default: 0
    field :active, :boolean, default: true
    field :collected, :boolean, default: true
    belongs_to :user, User

    timestamps()
  end

  def changeset(trash, attrs) do
    trash
    |> cast(attrs, @db_columns)
  end

end
