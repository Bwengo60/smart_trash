defmodule SmartTrashWeb.DashboardLive do
  use SmartTrashWeb, :live_view

  def mount(_socket, _session, socket) do
    socket =
      socket
      |> assign(:message, "")

    {:ok, socket}
  end
end
