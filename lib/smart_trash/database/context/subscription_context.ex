defmodule SmartTrash.Database.Context.SubscriptionContext do
  alias SmartTrash.Database.Schema.Subscriptions
  alias SmartTrash.Repo
  import Ecto.Query

  def create_subscription(attrs) do
    %Subscriptions{}
    |> Repo.insert(attrs)
  end

  def list_subscription do
    Subscriptions
    |> Repo.all()
  end

  def get_subscription_by_user(id) do
    Subscriptions
    |> preload(:subscription_package)
    |> where([a], a.user_id == ^id)
    |> Repo.one!()
  end
end
