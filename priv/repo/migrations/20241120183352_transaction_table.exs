defmodule SmartTrash.Repo.Migrations.TransactionTable do
  use Ecto.Migration

  def change do
    create table(:transactions_tbl) do
      add :user_id, references(:users_table, on_delete: :delete_all)

      add :amount, :integer
      add :subscription_package_id, references(:subscription_packages)
      add :debit, :integer
      add :credit, :integer
      add :status, :string
      add :channel, :string
      add :txn_number, :string

      timestamps()
    end
  end
end
