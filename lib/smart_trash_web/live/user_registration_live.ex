defmodule SmartTrashWeb.UserRegistrationLive do
  use SmartTrashWeb, :live_view

  alias SmartTrash.Accounts
  alias SmartTrash.Accounts.User
  alias SmartTrash.Database.Context.SubscriptionContext
  alias SmartTrash.Database.Context.{SubscriptionPackageContext}
  alias Ecto.Multi
  alias SmartTrash.Database.Schema.Subscriptions

  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto py-8 px-4">
      <.header class="text-center mb-8">
        Register for an account
        <:subtitle>
          Already registered?
          <.link navigate={~p"/users/log_in"} class="font-semibold text-brand hover:underline">
            Sign in
          </.link>
          to your account now.
        </:subtitle>
      </.header>

      <div class="space-y-8">
        <div class="relative">
          <nav aria-label="Progress" class="mb-8">
            <ol role="list" class="flex items-center justify-center">
              <%= for {step, index} <- Enum.with_index(["Account Type", "Subscription", "Personal Info", "Bin Setup", "Review"]) do %>
                <li class={[
                  "flex items-center",
                  index != 4 && "flex-1"
                ]}>
                  <div class="flex flex-col items-center">
                    <div class={[
                      "w-8 h-8 rounded-full flex items-center justify-center text-sm font-semibold",
                      current_step_class(@current_step, index + 1)
                    ]}>
                      <%= index + 1 %>
                    </div>
                    <span class="mt-2 text-sm font-medium"><%= step %></span>
                  </div>
                  <%= if index != 4 do %>
                    <div class="flex-1 h-px bg-gray-200 mx-4"></div>
                  <% end %>
                </li>
              <% end %>
            </ol>
          </nav>
        </div>

        <%= if @step_1 do %>
          <div class="space-y-6">
            <h2 class="text-2xl font-semibold text-center text-gray-900">Choose Account Type</h2>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <button
                phx-click="step_1"
                phx-value-usr_type="individual"
                class="flex flex-col items-center p-6 bg-white rounded-xl shadow-sm border-2 border-transparent hover:border-brand transition-all"
              >
                <div class="w-16 h-16 bg-brand/10 rounded-full flex items-center justify-center mb-4">
                  <.icon name="hero-user" class="w-8 h-8 text-brand" />
                </div>
                <h3 class="text-xl font-semibold mb-2">Individual</h3>
                <p class="text-gray-600 text-center">Perfect for homes and small businesses</p>
              </button>

              <button
                phx-click="step_1"
                phx-value-usr_type="corporate"
                class="flex flex-col items-center p-6 bg-white rounded-xl shadow-sm border-2 border-transparent hover:border-brand transition-all"
              >
                <div class="w-16 h-16 bg-brand/10 rounded-full flex items-center justify-center mb-4">
                  <.icon name="hero-building-office" class="w-8 h-8 text-brand" />
                </div>
                <h3 class="text-xl font-semibold mb-2">Corporate</h3>
                <p class="text-gray-600 text-center">Ideal for companies and large businesses</p>
              </button>
            </div>
          </div>
        <% end %>

        <%= if @step_2 do %>
          <div class="space-y-6">
            <h2 class="text-2xl font-semibold text-center text-gray-900">Select Your Plan</h2>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
              <%= for sub <- @subscription_packages do %>
                <div class="flex flex-col p-6 bg-white rounded-xl shadow-sm border-2 border-transparent hover:border-brand transition-all">
                  <h3 class="text-xl font-semibold mb-4"><%= sub.name %></h3>
                  <div class="flex items-baseline mb-6">
                    <span class="text-3xl font-semibold">K</span>
                    <span class="text-5xl font-bold"><%= sub.amount %></span>
                    <span class="text-gray-600 ml-2">/Trash</span>
                  </div>
                  <p class="text-gray-600 mb-6 flex-grow"><%= sub.description %></p>
                  <button
                    type="button"
                    phx-click="select_plan"
                    phx-value-plan={sub.id}
                    class="w-full px-4 py-2 bg-brand text-white rounded-lg hover:bg-brand/90 transition-colors"
                  >
                    Choose Plan
                  </button>
                </div>
              <% end %>
            </div>
          </div>
        <% end %>

        <%= if @step_3 do %>
          <.simple_form
            for={@form}
            id="registration_form"
            phx-submit="save_personal_info"
            phx-change="validate"
          >
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <.input field={@form[:first_name]} type="text" label="First Name" required />
              <.input field={@form[:last_name]} type="text" label="Last Name" required />
              <.input field={@form[:email]} type="email" label="Email" required />
              <.input field={@form[:phone_number]} type="tel" label="Phone Number" required />
              <.input field={@form[:username]} type="text" label="Username" required />
              <.input field={@form[:password]} type="password" label="Password" required />
              <div class="col-span-2">
                <.input field={@form[:address]} type="text" label="Address" required />
              </div>
            </div>

            <:actions>
              <.button class="w-full mt-6">Continue</.button>
            </:actions>
          </.simple_form>
        <% end %>

        <%= if @step_4 do %>
          <div class="space-y-6">
            <h2 class="text-2xl font-semibold text-center text-gray-900">Add Your Trash Bins</h2>
            <form phx-submit="save_bins" class="space-y-4">
              <%= for index <- 1..@bin_count do %>
                <div class="flex gap-4">
                  <div class="flex-grow">
                    <label class="block text-sm font-medium text-gray-700 mb-1">
                      Bin Code <%= index %>
                    </label>
                    <input
                      type="text"
                      name={"bin_#{index}"}
                      class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-brand focus:border-brand"
                      required
                    />
                  </div>
                  <%= if index == @bin_count do %>
                    <button
                      type="button"
                      phx-click="add_bin"
                      class="self-end px-4 py-2 text-brand border-2 border-brand rounded-lg hover:bg-brand/10"
                    >
                      Add Bin
                    </button>
                  <% end %>
                </div>
              <% end %>

              <.button class="w-full mt-6">Continue</.button>
            </form>
          </div>
        <% end %>

        <%= if @step_5 do %>
          <div class="space-y-6">
            <h2 class="text-2xl font-semibold text-center text-gray-900">Review Your Information</h2>
            <div class="bg-white rounded-xl shadow-sm p-6 space-y-6">
              <div class="grid grid-cols-2 gap-4">
                <div>
                  <h3 class="font-semibold mb-2">Account Type</h3>
                  <p class="text-gray-600"><%= String.capitalize(@registration_data.user_type) %></p>
                </div>
                <div>
                  <h3 class="font-semibold mb-2">Selected Plan</h3>
                  <p class="text-gray-600"><%= @registration_data.plan.name %></p>
                </div>
                <div>
                  <h3 class="font-semibold mb-2">Contact Information</h3>
                  <p class="text-gray-600">
                    <%= @registration_data.first_name %> <%= @registration_data.last_name %><br/>
                    <%= @registration_data.email %><br/>
                    <%= @registration_data.phone_number %>
                  </p>
                </div>
                <div>
                  <h3 class="font-semibold mb-2">Registered Bins</h3>
                  <p class="text-gray-600">
                    <%= for bin <- @registration_data.bins do %>
                      <%= bin %><br/>
                    <% end %>
                  </p>
                </div>
              </div>

              <div class="flex justify-end gap-4">
                <.button
                  type="button"
                  phx-click="edit_registration"
                  class="bg-gray-100 hover:bg-gray-200 text-gray-700"
                >
                  Edit Information
                </.button>
                <.button phx-click="submit_registration">
                  Complete Registration
                </.button>
              </div>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})
    subscription_packages = SubscriptionPackageContext.list_active_subscriptions()

    socket =
      socket
      |> assign(:current_step, 1)
      |> assign(:step_1, true)
      |> assign(:step_2, false)
      |> assign(:step_3, false)
      |> assign(:step_4, false)
      |> assign(:step_5, false)
      |> assign(:bin_count, 1)
      |> assign(:subscription_packages, subscription_packages)
      |> assign(:registration_data, %{})
      |> assign(:check_errors, false)
      |> assign_form(changeset)

    {:ok, socket}
  end

  def handle_event("step_1", %{"usr_type" => user_type}, socket) do
    registration_data = Map.put(socket.assigns.registration_data, :user_type, user_type)

    {:noreply,
     socket
     |> assign(:registration_data, registration_data)
     |> assign(:current_step, 2)
     |> assign(:step_1, false)
     |> assign(:step_2, true)}
  end

  def handle_event("select_plan", %{"plan" => plan_id}, socket) do
    plan = Enum.find(socket.assigns.subscription_packages, &(&1.id == String.to_integer(plan_id)))

    registration_data = Map.put(socket.assigns.registration_data, :plan, plan)

    {:noreply,
     socket
     |> assign(:registration_data, registration_data)
     |> assign(:current_step, 3)
     |> assign(:step_2, false)
     |> assign(:step_3, true)}
  end

  def handle_event("save_personal_info", %{"user" => user_params}, socket) do
    case validate_personal_info(user_params) do
      {:ok, validated_params} ->
        registration_data =
          Map.merge(socket.assigns.registration_data, %{
            first_name: validated_params.first_name,
            last_name: validated_params.last_name,
            email: validated_params.email,
            phone_number: validated_params.phone_number,
            username: validated_params.username,
            password: validated_params.password,
            address: validated_params.address
          })

        {:noreply,
         socket
         |> assign(:registration_data, registration_data)
         |> assign(:current_step, 4)
         |> assign(:step_3, false)
         |> assign(:step_4, true)}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(:check_errors, true)
         |> assign_form(changeset)}
    end
  end

  def handle_event("add_bin", _params, socket) do
    {:noreply, assign(socket, :bin_count, socket.assigns.bin_count + 1)}
  end

  def handle_event("save_bins", params, socket) do
    bins =
      params
      |> Map.filter(fn {key, _} -> String.starts_with?(key, "bin_") end)
      |> Map.values()

    registration_data = Map.put(socket.assigns.registration_data, :bins, bins)

    {:noreply,
     socket
     |> assign(:registration_data, registration_data)
     |> assign(:current_step, 5)
     |> assign(:step_4, false)
     |> assign(:step_5, true)}
  end

  # ... previous code remains the same until the transaction handling ...

  def handle_event("submit_registration", _params, socket) do
    %{registration_data: data} = socket.assigns

    Multi.new()
    |> Multi.insert(:user, fn _changes ->
      User.registration_changeset(%User{}, %{
        first_name: data.first_name,
        last_name: data.last_name,
        email: data.email,
        phone_number: data.phone_number,
        username: data.username,
        password: data.password,
        address: data.address,
        type: data.user_type
      })
    end)
    |> Multi.insert(:subscription, fn %{user: user} ->
      Subscriptions.changeset(%Subscriptions{}, %{
        user_id: user.id,
        subscription_package_id: data.plan.id,
        status: "active"
      })
    end)
    |> Multi.insert_all(:bins, SmartTrash.Bins, fn %{user: user} ->
      Enum.map(data.bins, fn bin_code ->
        %{
          code: bin_code,
          user_id: user.id,
          inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
          updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
        }
      end)
    end)
    |> SmartTrash.Repo.transaction()
    |> case do
      {:ok, %{user: user}} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        {:noreply,
         socket
         |> put_flash(:info, "Registration successful! Please check your email for confirmation instructions.")
         |> redirect(to: ~p"/users/log_in")}

      {:error, failed_operation, failed_value, _changes} ->
        error_message = transaction_error_message(failed_operation, failed_value)

        {:noreply,
         socket
         |> put_flash(:error, error_message)
         |> assign(:check_errors, true)}
    end
  end

  def handle_event("edit_registration", _params, socket) do
    {:noreply,
     socket
     |> assign(:current_step, 1)
     |> assign(:step_5, false)
     |> assign(:step_1, true)}
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  # Helper functions

  defp validate_personal_info(params) do
    types = %{
      first_name: :string,
      last_name: :string,
      email: :string,
      phone_number: :string,
      username: :string,
      password: :string,
      address: :string
    }

    {%{}, types}
    |> Ecto.Changeset.cast(params, Map.keys(types))
    |> Ecto.Changeset.validate_required(Map.keys(types))
    |> Ecto.Changeset.validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
    |> Ecto.Changeset.validate_length(:password, min: 8)
    |> case do
      %{valid?: true} = changeset -> {:ok, Ecto.Changeset.apply_changes(changeset)}
      changeset -> {:error, changeset}
    end
  end

  defp transaction_error_message(failed_operation, failed_value) do
    case failed_operation do
      :user ->
        case failed_value.errors do
          [{:email, _}] -> "Email already taken"
          [{:username, _}] -> "Username already taken"
          _ -> "Error creating user account"
        end

      :subscription ->
        "Error creating subscription"

      :bins ->
        "Error registering bins"

      _ ->
        "An unexpected error occurred"
    end
  end

  defp current_step_class(current_step, step_number) when current_step >= step_number do
    "bg-brand text-white"
  end

  defp current_step_class(_current_step, _step_number) do
    "bg-gray-100 text-gray-500"
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
