defmodule SmartTrash.Database.Schema.ManufacturedTrashBin do
  use Ecto.Schema
  import Ecto.Changeset

  schema "manufactured_trash_bins" do
    field :trash_code, :string
    field :mac_address, :string
    field :active, :boolean

    timestamps()
  end

  def changeset(man_trash_bin, attrs) do
    man_trash_bin
    |> cast(attrs, [:trash_code, :mac_address, :active])
  end

end
