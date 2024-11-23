defmodule SmartTrash.Database.Context.TransactionsContext do
  alias SmartTrash.Database.Schema.Transactions
  alias SmartTrash.Repo
  import Ecto.Query

  def create_transaction(attrs) do
    %Transactions{}
    |>Transactions.changeset(attrs)
    |> Repo.insert!()
  end

  def list_transactions do
    Transactions
    |>preload([:user, :subscription_package])
    |> Repo.all()
  end

  def list_user_transactions(id) do
    Transactions
    |> where([a], a.user_id==^id)
    |>preload([:user, :subscription_package])

    |> Repo.all()
  end
end
