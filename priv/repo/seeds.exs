#     mix run priv/repo/seeds.exs

alias SmartTrash.Setup.{RolesSetup, SubscriptionPackage, ManufacturedTrashBin, UserSetup}

RolesSetup.process()
SubscriptionPackage.process()
ManufacturedTrashBin.process()
UserSetup.process()
