defmodule SmartTrash.Database.Schema.Subscriptions do
  import Ecto.Changeset
  use Ecto.Schema

  schema "subscriptions_table" do
    belongs_to :user, SmartTrash.Accounts.User
    belongs_to :subscription_package, SmartTrash.Database.Schema.SubscriptionPackageTable
    field :status, :string
    field :subscription_due, :naive_datetime
    timestamps()
  end

  def changeset(subscription, attrs) do
    subscription
    |>cast(attrs, [:subscription_due, :user_id, :status, :subscription_package_id])
  end
end
