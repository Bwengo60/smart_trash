#     mix run priv/repo/seeds.exs

alias SmartTrash.Setup.{RolesSetup, SubscriptionPackage, ManufacturedTrashBin}

RolesSetup.process()
SubscriptionPackage.process()
ManufacturedTrashBin.process()
