defmodule SmartTrash.Setup.UserSetup do
  alias SmartTrash.Accounts

  def process do
    [
      %{
        first_name: "Muhammad",
        last_name: "Bwengo",
        password: "dev12345",
        username: "bwengoman",
        email: "muhammadbwengo60@gmail.com",
        role_id: 1,
        phone_number: "0979166959",
        address: "Lilanda 404/06"
      }
    ]
    |> Enum.map(fn data ->
      Accounts.register_user(data)
    end)
  end
end
