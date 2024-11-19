defmodule SmartTrash.Database.Schema.SubscriptionPackageTable do
  use Ecto.Schema
  import Ecto.Changeset

  schema "subscription_packages" do

    field :name, :string
    field :description, :string
    field :amount, :integer
    field :type, :string
    field :active, :boolean, default: true

    timestamps()
  end

  def changeset(sub_packages, attrs) do
    sub_packages
    |>cast(attrs, [:name, :description, :amount, :active, :type])
  end

end
