defmodule SmartTrashWeb.SubscriptionPayment do
  use SmartTrashWeb, :live_view
  alias SmartTrash.Repo
  alias SmartTrash.Accounts
  alias SmartTrash.Database.Context.{SubscriptionContext, TransactionsContext}

  def mount(_params, session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])
    |> Repo.preload([:role])

    subscription = SubscriptionContext.get_subscription_by_user(user.id)

    mobile_money_form = to_form(%{
      "phone_number" => "",
      "amount" => ""
    })

    card_form = to_form(%{
      "card_number" => "",
      "expiry" => "",
      "cvv" => ""
    })

    socket = socket
    |> assign(:user, user)
    |> assign(:user_subscription, subscription)
    |> assign(:payment_method, nil)
    |> assign(:mobile_money_form, mobile_money_form)
    |> assign(:card_form, card_form)

    {:ok, socket}
  end

  @impl true
  def handle_event("select_payment_method", %{"method" => method}, socket) do
    {:noreply, assign(socket, :payment_method, method)}
  end

  @impl true
  def handle_event("validate_mobile_money", params, socket) do
    form = to_form(params["mobile_money"] || %{}, action: :validate)
    {:noreply, assign(socket, :mobile_money_form, form)}
  end

  @impl true
  def handle_event("validate_card_payment", params, socket) do
    form = to_form(params["card_payment"] || %{}, action: :validate)
    {:noreply, assign(socket, :card_form, form)}
  end

  @impl true
  def handle_event("save_mobile_money_transaction", params, socket) do
    # Add your transaction logic here

    case TransactionsContext.create_transaction(%{
      amount: params["amount"],
      txn_number: params["phone_number"],
      user_id: socket.assigns.user.id,
      subscription_package_id: socket.assigns.user_subscription.subscription_package_id,
      credit: 0,
      debit: params["amount"],
      status: "PENDING",
      channel: "mobile money"
      })
    do
       _txn ->
        {:noreply,
          socket
          |> put_flash(:info, "Mobile Money Payment Processed!")
          |> push_navigate(to: "/subscription/payment")
        }
      {:error, reason} ->
        {:noreply,
          socket
          |> put_flash(:error, "Transaction Failed! #{reason}")
          |> push_navigate(to: "/subscription/payment")

        }
    end

  end

  @impl true
  def handle_event("save_card_transaction", %{"card_payment" => params}, socket) do
    # Add your transaction logic here
    {:noreply,
      socket
      |> put_flash(:info, "Card Payment Processed!")
      |> push_navigate(to: "/dashboard")
    }
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-6 bg-white dark:bg-gray-900">
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div class="space-y-6">
          <div class="bg-gray-100 dark:bg-gray-800 p-6 rounded-lg shadow-md">
            <h2 class="text-2xl font-bold mb-4 text-gray-900 dark:text-white">
              Current Subscription
            </h2>
            <div class="flex justify-between items-center">
              <div>
                <p class="text-lg font-semibold text-gray-700 dark:text-gray-300">
                  <%= @user_subscription.subscription_package.name %>
                </p>
                <p class="text-sm text-gray-500">
                  Expires: <%= @user_subscription.subscription_due %>
                </p>
              </div>
              <span class="text-lg font-bold text-gray-900 dark:text-white">
                k<%= @user_subscription.subscription_package.amount %>
              </span>
            </div>
          </div>

          <div class="bg-gray-100 dark:bg-gray-800 p-6 rounded-lg shadow-md">
            <h2 class="text-2xl font-bold mb-4 text-gray-900 dark:text-white">
              Choose Payment Method
            </h2>
            <div class="grid grid-cols-2 gap-4">
              <.button
                phx-click="select_payment_method"
                phx-value-method="mobile_money"
                class={[
                  "w-full p-4 rounded-lg",
                  if(@payment_method == "mobile_money",
                     do: "bg-blue-600 text-white",
                     else: "bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300")
                ]}
              >
                Mobile Money
              </.button>
              <.button
                phx-click="select_payment_method"
                phx-value-method="card"
                class={[
                  "w-full p-4 rounded-lg",
                  if(@payment_method == "card",
                     do: "bg-blue-600 text-white",
                     else: "bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300")
                ]}
              >
                Card Payment
              </.button>
            </div>
          </div>
        </div>

        <div>
          <%= if @payment_method == "mobile_money" do %>
            <div class="bg-gray-100 dark:bg-gray-800 p-6 rounded-lg shadow-md">
              <h2 class="text-2xl font-bold mb-4 text-gray-900 dark:text-white">
                Mobile Money Payment
              </h2>
              <.form
                for={@mobile_money_form}
                phx-change="validate_mobile_money"
                phx-submit="save_mobile_money_transaction"
                class="space-y-4"
              >
                <.input
                  field={@mobile_money_form[:phone_number]}
                  type="text"
                  label="Phone Number"
                  placeholder="0971234567"
                  required
                />
                <.input
                  field={@mobile_money_form[:amount]}
                  type="number"
                  label="Amount"
                  step="0.01"
                  value={@user_subscription.subscription_package.amount}
                  readonly
                />
                <.button type="submit" class="w-full">
                  Pay Now
                </.button>
              </.form>
            </div>
          <% end %>

          <%= if @payment_method == "card" do %>
            <div class="bg-gray-100 dark:bg-gray-800 p-6 rounded-lg shadow-md">
              <h2 class="text-2xl font-bold mb-4 text-gray-900 dark:text-white">
                Card Payment
              </h2>
              <.form
                for={@card_form}
                phx-change="validate_card_payment"
                phx-submit="save_card_transaction"
                class="space-y-4"
              >
                <.input
                  field={@card_form[:card_number]}
                  type="text"
                  label="Card Number"
                  placeholder="4242 4242 4242 4242"
                  required
                />
                <div class="grid grid-cols-2 gap-4">
                  <.input
                    field={@card_form[:expiry]}
                    type="text"
                    label="Expiry (MM/YY)"
                    placeholder="12/24"
                    required
                  />
                  <.input
                    field={@card_form[:cvv]}
                    type="text"
                    label="CVV"
                    placeholder="123"
                    required
                  />
                </div>
                <.input
                  field={@card_form[:amount]}
                  type="number"
                  label="Amount"
                  step="0.01"
                  value={@user_subscription.subscription_package.amount}
                  readonly
                />
                <.button type="submit" class="w-full">
                  Pay Now
                </.button>
              </.form>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
