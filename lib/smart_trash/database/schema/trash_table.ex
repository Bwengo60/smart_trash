defmodule SmartTrash.Database.Schema.Trash do
  use Ecto.Schema
  import Ecto.Changeset
  alias SmartTrash.Accounts.User

  @db_columns [
    :trash_code,
    :trash_levels,
    :active,
    :collected,
    :user_id,
    :name,
    :collection_count
  ]

  schema "trash_table" do
    field :trash_code, :string
    field :trash_levels, :integer, default: 0
    field :active, :boolean, default: true
    field :collected, :boolean, default: true
    field :name, :string
    field :collection_count, :integer, default: 0
    belongs_to :user, User

    timestamps()
  end

  def changeset(trash, attrs) do
    trash
    |> cast(attrs, @db_columns)
  end

end
