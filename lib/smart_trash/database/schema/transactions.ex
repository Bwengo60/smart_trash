defmodule SmartTrash.Database.Schema.Transactions do
  use Ecto.Schema
  import Ecto.Changeset
  alias SmartTrash.Accounts.User
  alias SmartTrash.Database.Schema.SubscriptionPackageTable

  schema "transactions_tbl" do
    belongs_to :user, User
    belongs_to :subscription_package, SubscriptionPackageTable

    field :amount, :integer
    field :debit, :integer
    field :credit, :integer
    field :status, :string
    field :channel, :string
    field :txn_number, :string

    timestamps()
  end

  def changeset(txn, attrs) do
    txn
    |>cast(attrs, [:amount, :status, :credit, :debit, :user_id, :subscription_package_id, :channel, :txn_number])
  end

end
