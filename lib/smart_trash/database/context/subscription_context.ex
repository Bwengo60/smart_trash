defmodule SmartTrash.Database.Context.SubscriptionContext do
  alias SmartTrash.Database.Schema.Subscriptions
  alias SmartTrash.Repo

  def create_subscription(attrs) do
    %Subscriptions{}
    |> Repo.insert(attrs)
  end

  def list_subscription do
    Subscriptions
    |> Repo.all()
  end
end
