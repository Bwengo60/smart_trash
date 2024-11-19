defmodule SmartTrash.Database.Context.SubscriptionPackageContext do
  alias SmartTrash.Database.Schema.SubscriptionPackageTable
  import Ecto.Query
  alias SmartTrash.Repo

  def create_subscription(attrs) do
    %SubscriptionPackageTable{}
    |>SubscriptionPackageTable.changeset(attrs)
    |>Repo.insert!()
  end

  def list_subscriptions do
    SubscriptionPackageTable
    |> Repo.all()
  end

  def list_active_subscriptions do
    SubscriptionPackageTable
    |> where([a], a.active==true)
    |> Repo.all()
  end

  def get_subscription(id) do
    SubscriptionPackageTable
    |> Repo.get!(id)
  end
end
