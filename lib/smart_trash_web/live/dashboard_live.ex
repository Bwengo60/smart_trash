defmodule SmartTrashWeb.DashboardLive do
  use SmartTrashWeb, :live_view
  alias SmartTrash.Database.Context.TrashContext
  alias SmartTrash.Database.Context.SubscriptionContext
  alias SmartTrash.Accounts
  alias SmartTrash.Repo
  import Ecto.Query

  def mount(_params, session, socket) do

    if connected?(socket) do
      :timer.send_interval(30000, self(), :update_charts)  # Updates every 30 seconds
    end

    user = Accounts.User
           |> preload(:role)
           |> Repo.get!(Accounts.get_user_by_session_token(session["user_token"]).id)


    user_trash = TrashContext.list_trash_by_user(user.id)
    subscription = SubscriptionContext.get_subscription_by_user(user.id)

    charts_data = prepare_charts_data(user_trash)
    subscription_info = prepare_subscription_info(subscription)

    socket = socket
    |> assign(:message, "")
    |> assign(:user_trash, user_trash)
    |> assign(:user_trash_count, length(user_trash))
    |> assign(:user_subscription, subscription)
    |> assign(:charts_data, charts_data)
    |> assign(:subscription_info, subscription_info)
    |> assign(:user, user)
    |> push_event("init-charts", %{charts: charts_data})

    {:ok, socket}
  end

  defp prepare_charts_data(trash_bins) do
    trash_bins
    |> Enum.map(fn bin ->
      # Ensure trash_levels is a valid percentage between 0 and 100
      level = bin.trash_levels || 0
      level = min(max(level, 0), 100)

      %{
        id: bin.id,
        series: 68,
        labels: ["Trash Level"],
        title: "Trash Code: #{bin.trash_code}",
        color: get_level_color(level)
      }
    end)
  end

  defp get_level_color(level) do
    cond do
      level >= 80 -> "#EF4444" # red
      level >= 50 -> "#F59E0B" # yellow
      true -> "#10B981" # green
    end
  end

  defp prepare_subscription_info(subscription) do
    days_remaining = Date.diff(subscription.subscription_due, Date.utc_today())

    %{
      package_name: subscription.subscription_package.name,
      inserted_at: Date.to_string(subscription.inserted_at),
      subscription_due: Date.to_string(subscription.subscription_due),
      days_remaining: days_remaining,
      status: if(days_remaining > 0, do: "Active", else: "Expired")
    }
  end

  defp format_last_collection_date(user_trash) do
    case Enum.max_by(user_trash, &(&1.updated_at), fn -> nil end) do
      nil -> "No collections yet"
      last_collection ->
        # Convert to Date if it's not already a Date
        last_date = case last_collection.updated_at do
          %Date{} -> last_collection.updated_at
          %DateTime{} -> DateTime.to_date(last_collection.updated_at)
          %NaiveDateTime{} -> NaiveDateTime.to_date(last_collection.updated_at)
          date_str when is_binary(date_str) ->
            case Date.from_iso8601(date_str) do
              {:ok, parsed_date} -> parsed_date
              _ -> Date.utc_today()
            end
          _ -> Date.utc_today()
        end

        days_ago = Date.diff(Date.utc_today(), last_date)

        cond do
          days_ago == 0 -> "Today"
          days_ago == 1 -> "Yesterday"
          days_ago < 7 -> "#{days_ago} days ago"
          days_ago < 30 -> "#{div(days_ago, 7)} weeks ago"
          true ->
            # For longer periods, use a full date format
            Date.to_string(last_date)
        end
    end
  end

  @spec handle_info(:update_charts, %{
          :assigns =>
            atom()
            | %{
                :user => atom() | %{:id => any(), optional(any()) => any()},
                optional(any()) => any()
              },
          optional(any()) => any()
        }) :: {:noreply, map()}
  def handle_info(:update_charts, socket) do
    user_trash = TrashContext.list_trash_by_user(socket.assigns.user.id)
    charts_data = prepare_charts_data(user_trash)

    {:noreply, socket
      |> assign(:user_trash, user_trash)
      |> assign(:charts_data, charts_data)
      |> push_event("update-charts", %{charts: charts_data})}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 p-8">
      <div class="container mx-auto space-y-8">
        <%!-- <h1 class="text-4xl font-bold text-gray-800 mb-6">Smart Trash Dashboard</h1> --%>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <!-- Trash Bins Counter -->
          <div class="bg-white rounded-2xl shadow-lg p-6 transform transition-all hover:scale-105 hover:shadow-xl">
            <div class="flex justify-between items-center">
              <div>
                <h2 class="text-xl font-semibold text-gray-700 mb-2">Active Trash Bins</h2>
                <div class="text-4xl font-bold text-brand">
                  <%= @user_trash_count %>/<%= @user_subscription.subscription_package.limit %>
                </div>
              </div>
              <div class="bg-blue-100 rounded-full p-4">
                <svg class="h-8 w-8 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h3a1 1 0 011 1v5m-4 0h4"></path>
                </svg>
              </div>
            </div>
          </div>

          <!-- Subscription Status -->
          <div class="bg-gradient-to-br from-purple-500 to-brand rounded-2xl shadow-lg p-6 text-white transform transition-all hover:scale-105 hover:shadow-xl">
            <h2 class="text-xl font-semibold mb-4">Subscription Status</h2>
            <div class="space-y-2">
              <p>Package: <span class="font-bold"><%= @subscription_info.package_name %></span></p>
              <p>Status:
                <span class={"font-bold #{if @subscription_info.status == "Active", do: "text-green-300", else: "text-red-300"}"}><%= @subscription_info.status %></span>
              </p>
              <%= if @subscription_info.package_name in ["Home", "Coporate"] do %>
                <p>Days Remaining: <span class="font-bold"><%= @subscription_info.days_remaining %></span></p>
              <% end %>
            </div>
          </div>

          <!-- Collection History -->
          <div class="bg-white rounded-2xl shadow-lg p-6 transform transition-all hover:scale-105 hover:shadow-xl">
            <h2 class="text-xl font-semibold text-gray-700 mb-4">Collection History</h2>
            <div class="space-y-2">
              <p class="text-gray-600">
                Total Collections:
                <span class="font-bold text-green-600">
                  <%= Enum.reduce(@user_trash, 0, fn trash, acc -> acc + (trash.collection_count || 0) end) %>
                </span>
              </p>

              <p class="text-gray-600">
                Last Collection:
                <span class="font-bold text-blue-600">
                  <%= format_last_collection_date(@user_trash) %>
                </span>
              </p>

            </div>
          </div>
        </div>

        <!-- Trash Level Charts -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <%= for chart <- @charts_data do %>
            <div class="bg-white rounded-2xl shadow-lg p-6 transform transition-all hover:scale-105 hover:shadow-xl">
              <h3 class="text-xl font-bold mb-4 text-gray-800"><%= chart.title %></h3>
              <div
                id={"chart-#{chart.id}"}
                phx-hook="Charts"
                phx-update="ignore"
                class="w-full h-64"
              ></div>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("init-charts", _params, socket) do
    {:noreply, socket}
  end
end
