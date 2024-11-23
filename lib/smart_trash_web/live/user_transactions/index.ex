defmodule SmartTrashWeb.UserTransactions.Index do
  use SmartTrashWeb, :live_view
  alias SmartTrash.Accounts
  alias SmartTrash.Database.Context.TransactionsContext

  def mount(_params, session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])

    socket =
      socket
      |> assign(:transactions, [])
      |> assign(:search_term, "")
      |> assign(:time_filter, "30")
      |> assign(:page_title, "Transaction History")
      |> load_transactions(user.id)

    {:ok, socket}
  end

  def handle_event("search", %{"search_term" => search_term}, socket) do
    {:noreply,
      socket
      |> assign(:search_term, search_term)
      |> filter_transactions()
    }
  end

  def handle_event("filter_time", %{"time_filter" => time_filter}, socket) do
    {:noreply,
      socket
      |> assign(:time_filter, time_filter)
      |> filter_transactions()
    }
  end

  defp load_transactions(socket, user_id) do
    transactions = TransactionsContext.list_user_transactions(user_id)
    assign(socket, :all_transactions, transactions)
    |> filter_transactions()
  end

  defp filter_transactions(%{assigns: %{all_transactions: transactions, search_term: search_term, time_filter: time_filter}} = socket) do
    filtered_transactions =
      transactions
      |> Enum.filter(&match_search?(&1, search_term))
      |> Enum.filter(&within_time_range?(&1, time_filter))

    assign(socket, :transactions, filtered_transactions)
  end

  defp match_search?(transaction, "") do
    true
  end

  defp match_search?(transaction, search_term) do
    search_term = String.downcase(search_term)

    String.contains?(String.downcase(transaction.txn_number || ""), search_term) ||
      String.contains?(String.downcase(format_date(transaction.inserted_at)), search_term)
  end

  defp within_time_range?(transaction, time_filter) do
    days = String.to_integer(time_filter)

    # Convert current time to NaiveDateTime in UTC
    cutoff_date = NaiveDateTime.utc_now()
      |> NaiveDateTime.add(-days * 24 * 60 * 60)

    case transaction.inserted_at do
      %NaiveDateTime{} = date ->
        NaiveDateTime.compare(date, cutoff_date) in [:gt, :eq]
      %DateTime{} = date ->
        NaiveDateTime.compare(DateTime.to_naive(date), cutoff_date) in [:gt, :eq]
      _ ->
        false
    end
  end

  defp format_date(datetime) do
    case datetime do
      %NaiveDateTime{} = dt ->
        Calendar.strftime(dt, "%B %d, %Y")
      %DateTime{} = dt ->
        dt
        |> DateTime.to_naive()
        |> Calendar.strftime("%B %d, %Y")
      _ ->
        "Invalid date"
    end
  end

  defp format_amount(amount) when is_number(amount) do
    :erlang.float_to_binary(amount / 1, [decimals: 2])
  end

  defp format_amount(_), do: "0.00"

  defp status_color(status) do
    case status do
      "completed" -> "bg-green-100 text-green-800"
      "pending" -> "bg-yellow-100 text-yellow-800"
      "failed" -> "bg-red-100 text-red-800"
      _ -> "bg-gray-100 text-gray-800"
    end
  end

  def render(assigns) do
    ~H"""
    <div class="px-4 sm:px-6 lg:px-8 py-8">
      <div class="sm:flex sm:items-center">
        <div class="sm:flex-auto">
          <h1 class="text-2xl font-semibold text-gray-900">Transaction History</h1>
        </div>
      </div>

      <div class="mt-8 flex flex-col">
        <div class="flex flex-wrap gap-4 mb-6">
          <!-- Search Input -->
          <div class="relative flex-1 max-w-sm">
            <div class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
              <svg class="w-4 h-4 text-gray-500" aria-hidden="true" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
            </div>
            <form phx-change="search" phx-submit="prevent_submit">
              <input
                type="text"
                name="search_term"
                class="block w-full p-2.5 pl-10 text-sm border rounded-lg bg-gray-50 focus:ring-blue-500 focus:border-blue-500"
                placeholder="Search transactions..."
                value={@search_term}
                phx-debounce="300"
              />
            </form>
          </div>

          <!-- Time Filter -->
          <div class="w-48">
            <form phx-change="filter_time">
              <select
                name="time_filter"
                class="block w-full p-2.5 text-sm border rounded-lg bg-gray-50 focus:ring-blue-500 focus:border-blue-500"
                value={@time_filter}
              >
                <option value="1">Last 24 hours</option>
                <option value="7">Last 7 days</option>
                <option value="30">Last 30 days</option>
                <option value="90">Last 3 months</option>
                <option value="365">Last year</option>
              </select>
            </form>
          </div>
        </div>

        <div class="overflow-x-auto">
          <div class="inline-block min-w-full align-middle">
            <div class="overflow-hidden ring-1 ring-black ring-opacity-5 rounded-lg">
              <table class="min-w-full divide-y divide-gray-300">
                <thead class="bg-gray-50">
                  <tr>
                    <th scope="col" class="py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-gray-900">ID</th>
                    <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">Amount</th>
                    <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">Service</th>
                    <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">Status</th>
                    <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">Transaction ID</th>
                    <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">Channel</th>
                    <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">Date</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-gray-200 bg-white">
                  <%= for transaction <- @transactions do %>
                    <tr class="hover:bg-gray-50">
                      <td class="whitespace-nowrap py-4 pl-4 pr-3 text-sm font-medium text-gray-900">
                        <%= transaction.id %>
                      </td>
                      <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                        <%= format_amount(transaction.amount) %>
                      </td>
                      <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                        <%= transaction.subscription_package.name %>
                      </td>
                      <td class="whitespace-nowrap px-3 py-4 text-sm">
                        <span class={"inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium #{status_color(transaction.status)}"}>
                          <%= transaction.status %>
                        </span>
                      </td>
                      <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                        <%= transaction.txn_number %>
                      </td>
                      <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                        <%= transaction.channel %>
                      </td>
                      <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                        <%= format_date(transaction.inserted_at) %>
                      </td>
                    </tr>
                  <% end %>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
