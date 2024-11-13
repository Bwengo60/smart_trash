defmodule SmartTrash.Repo do
  use Ecto.Repo,
    otp_app: :smart_trash,
    adapter: Ecto.Adapters.Postgres
end
