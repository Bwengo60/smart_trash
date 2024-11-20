defmodule SmartTrash.Setup.RolesSetup do
  alias SmartTrash.Database.Context.RolesContext

  def process() do
    [
      %{
        group: "super_admin",
        permissions: [
          "admin_dashboard",
          "sms_management",
          "users_management",
          "trash_management"
        ],
        active: true
      },
      %{
        group: "trash_controller",
        permissions: [
          "trash_management",
          "trash_controller_dashboard"
        ],
        active: true
      },
      %{
        group: "client",
        permissions: [
          "trash_information",
          "user_profile",
          "user_dashboard",
          "user_transactions",
          "user_payment_portal"
        ],
        active: true
      },
      %{
        group: "dev",
        permissions: [
          "admin_dashboard",
          "sms_management",
          "users_management",
          "trash_management",
          "trash_controller_dashboard",
          "trash_information",
          "user_profile",
          "user_dashboard",
          "user_transactions",
          "user_payment_portal"

        ]
      }
    ]
    |>Enum.map(fn data ->
      RolesContext.create_role(data)
    end)
  end
end
