#     mix run priv/repo/seeds.exs

alias SmartTrash.Setup.{RolesSetup, SubscriptionPackage}

RolesSetup.process()
SubscriptionPackage.process()
