defmodule SmartTrashWeb.UserRegistrationLive do
  use SmartTrashWeb, :live_view

  alias SmartTrash.Accounts
  alias SmartTrash.Accounts.User
  alias SmartTrash.Database.Context.TrashBinContext
  alias SmartTrash.Database.Context.{SubscriptionPackageContext}
  alias SmartTrash.Database.Context.RolesContext
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

        <div class="mb-4">
          <%= if @current_step > 1 do %>
            <button
              type="button"
              phx-click="previous_step"
              class="flex items-center text-brand hover:text-brand/80"
            >
              <.icon name="hero-arrow-left" class="w-4 h-4 mr-2" />
              Back to previous step
            </button>
          <% end %>
        </div>

        <%= if @show_success do %>
          <div class="bg-green-50 p-6 rounded-xl text-center">
            <div class="w-16 h-16 mx-auto bg-green-100 rounded-full flex items-center justify-center mb-4">
              <.icon name="hero-check" class="w-8 h-8 text-green-600" />
            </div>
            <h3 class="text-xl font-semibold text-green-900 mb-2">Registration Successful!</h3>
            <p class="text-green-700 mb-4">
              Your account has been created. Please check your email for confirmation instructions.
            </p>
            <.link
              navigate={~p"/users/log_in"}
              class="inline-block px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700"
            >
              Go to Login
            </.link>
          </div>
        <% end %>

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
                  value={Map.get(@bin_values, "bin_#{index}", "")}
                  phx-change="validate_bin_code"
                  phx-debounce="300"
                  class={[
                    "w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-brand focus:border-brand",
                    if(@bin_errors["bin_#{index}"], do: "border-red-500", else: "border-gray-300")
                  ]}
                  required
                />
                <%= if error = @bin_errors["bin_#{index}"] do %>
                  <p class="mt-1 text-sm text-red-600"><%= error %></p>
                <% end %>
              </div>
              <div class="flex gap-2 self-end">
                <%= if index == @bin_count do %>
                  <button
                    type="button"
                    phx-click="add_bin"
                    class="px-4 py-2 text-brand border-2 border-brand rounded-lg hover:bg-brand/10"
                  >
                    Add Bin
                  </button>
                <% end %>
                <%= if @bin_count > 1 do %>
                  <button
                    type="button"
                    phx-click="remove_bin"
                    phx-value-index={index}
                    class="px-4 py-2 text-red-600 border-2 border-red-600 rounded-lg hover:bg-red-50"
                  >
                    Remove
                  </button>
                <% end %>
              </div>
            </div>
          <% end %>

          <.button class="w-full mt-6" disabled={!Enum.empty?(@bin_errors)}>Continue</.button>
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
      |> assign(:man_trash_list, TrashBinContext.list_active_man_trash)
      |> assign(:step_1, true)
      |> assign(:step_2, false)
      |> assign(:step_3, false)
      |> assign(:step_4, false)
      |> assign(:step_5, false)
      |> assign(:bin_count, 1)
      |> assign(:bin_values, %{})
      |> assign(:bin_errors, %{})
      |> assign(:show_success, false)
      |> assign(:subscription_packages, subscription_packages)
      |> assign(:registration_data, %{})
      |> assign(:check_errors, false)
      |> assign_form(changeset)

    {:ok, socket, layout: false}
  end

  def handle_event("validate_bin_code", params, socket) do
    # Extract the bin input that changed
    {bin_name, bin_value} =
      params
      |> Enum.find(fn {key, _value} -> String.starts_with?(key, "bin_") end)
      |> case do
        {key, value} -> {key, value}
        nil -> {nil, nil}
      end

    if bin_name do
      bin_values = Map.put(socket.assigns.bin_values, bin_name, bin_value)

      error = case validate_bin_code(bin_value, socket) do
        :ok -> nil
        {:error, message} -> message
      end

      bin_errors = if error,
        do: Map.put(socket.assigns.bin_errors, bin_name, error),
        else: Map.delete(socket.assigns.bin_errors, bin_name)

      {:noreply,
       socket
       |> assign(:bin_values, bin_values)
       |> assign(:bin_errors, bin_errors)}
    else
      {:noreply, socket}
    end
  end

  # Helper function to validate bin code
  defp validate_bin_code(""), do: :ok
  defp validate_bin_code(code, socket) do
    case Enum.find(socket.assigns.man_trash_list, fn trash -> trash.trash_code == code end) do
      nil -> {:error, "Invalid bin code"}
      _ -> :ok
    end
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

  def handle_event("previous_step", _params, socket) do
    {prev_step, new_assigns} = case socket.assigns.current_step do
      2 -> {1, %{step_1: true, step_2: false}}
      3 -> {2, %{step_2: true, step_3: false}}
      4 -> {3, %{step_3: true, step_4: false}}
      5 -> {4, %{step_4: true, step_5: false}}
      _ -> {1, %{}}
    end

    {:noreply,
     socket
     |> assign(:current_step, prev_step)
     |> assign(new_assigns)}
  end

  # Add handler for bin code validation


  # Modified handle_event for removing bins
  def handle_event("remove_bin", %{"index" => index}, socket) do
    index = String.to_integer(index)

    # Remove the bin and shift remaining values
    bin_values =
      socket.assigns.bin_values
      |> Enum.reduce(%{}, fn {k, v}, acc ->
        case Integer.parse(String.replace(k, "bin_", "")) do
          {n, ""} when n > index ->
            Map.put(acc, "bin_#{n-1}", v)
          {n, ""} when n < index ->
            Map.put(acc, "bin_#{n}", v)
          _ ->
            acc
        end
      end)

    {:noreply,
     socket
     |> assign(:bin_count, socket.assigns.bin_count - 1)
     |> assign(:bin_values, bin_values)
     |> assign(:bin_errors, Map.drop(socket.assigns.bin_errors, ["bin_#{index}"]))}
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
        role_id: RolesContext.get_role_by_name("client").id
      })
    end)
    |> Multi.insert(:subscriptions_table, fn %{user: user} ->
      Subscriptions.changeset(%Subscriptions{}, %{
        user_id: user.id,
        subscription_package_id: data.plan.id,
        status: "active",
        subscription_due: calculate_subscription_due(data.plan)  # Add this line
      })
    end)
    |> Multi.insert_all(:trash_table, SmartTrash.Database.Schema.Trash, fn %{user: user} ->
      Enum.map(data.bins, fn trash_code ->
        %{
          trash_code: trash_code,
          user_id: user.id,
          trash_levels: 0,
          active: true,
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

  # Add this helper function to calculate subscription due date
  defp calculate_subscription_due(_plan) do
     NaiveDateTime.add(NaiveDateTime.utc_now(), 30 * 24 * 60 * 60)  # Default to monthly
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
