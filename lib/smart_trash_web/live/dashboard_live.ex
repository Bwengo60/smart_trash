defmodule SmartTrashWeb.DashboardLive do
  use SmartTrashWeb, :live_view
  alias SmartTrash.Database.Context.TrashContext
  alias SmartTrash.Database.Context.SubscriptionContext
  alias SmartTrash.Accounts
  alias SmartTrash.Repo
  import Ecto.Query

  def mount(_params, session, socket) do
    user = Accounts.User
          |>preload(:role)
          |> Repo.get!(Accounts.get_user_by_session_token(session["user_token"]).id)

    # if user.role.group == "client" do

    # end

    socket =
      socket
      |> assign(:message, "")
      |> assign(:user_trash, TrashContext.list_trash_by_user(user.id))
      |> assign(:user_trash_count, user_trash_count(user.id))
      |> assign(:user_subscription, SubscriptionContext.get_subscription_by_user(user.id))

    {:ok, socket}
  end

  def user_trash_count(id) do
    Enum.count(TrashContext.list_trash_by_user(id))
  end

end
