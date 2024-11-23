defmodule SmartTrash.Setup.SubscriptionPackage do
  alias SmartTrash.Database.Context.SubscriptionPackageContext
  def process() do
    [
      %{
        name: "Home",
        description: "Can have upto 5 trash bins",
        amount: 200,
        active: true,
        type: "home",
        limit: "5",
        subscription_type: "monthly",


      },
      %{
        name: "Home Express",
        description: "Can have upto 10+ trash bins",
        amount: 50,
        type: "home",
        subscription_type: "daily",
        active: true,
        limit: "10+"
      },
      %{
        name: "Coporate",
        description: "can have upto 10+ trash bins",
        amount: 500,
        type: "coporate",
        active: true,
        subscription_type: "monthly",
        limit: "10+"

      },
      %{
        name: "Coporate Express",
        description: "Can have upot 10+ trash bins",
        amount: 150,
        type: "coporate",
        active: true,
        subscription_type: "daily",
        limit: "10+"
      }

    ]
    |>Enum.map(fn data ->
      SubscriptionPackageContext.create_subscription(data)
    end)
  end
end
