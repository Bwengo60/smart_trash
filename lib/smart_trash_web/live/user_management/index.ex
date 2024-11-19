defmodule SmartTrashWeb.UserManagement.Index do
    use SmartTrashWeb, :live_view
    alias SmartTrash.Accounts.User
    alias SmartTrash.Repo
    import Ecto.Query

    @impl true
    def mount(_params, _session, socket) do
      users = list_users()

      socket = socket
        |> assign(:page_title, "User Management")
        |> assign(:users, users)
        |> assign(:search_term, "")
        |> assign(:show_modal, false)
        |> assign(:editing_role, nil)
        |> assign_form(User.registration_changeset(%User{}, %{}))

      {:ok, socket}
    end

    @impl true
    def render(assigns) do
      ~H"""
      <div class="space-y-12 divide-y">
        <%!-- <div class="relative py-3 sm:max-w-5xl sm:mx-auto"> --%>
          <%!-- <div class="relative px-4 py-10 bg-white shadow-lg sm:rounded-3xl sm:p-20"> --%>
            <div class="max-w-4xl mx-auto">
              <div class="space-y-12 divide-y divide-gray-200">
                <div class="py-8 text-base leading-6 space-y-4 text-gray-700 sm:text-lg sm:leading-7">
                  <div class="flex justify-between items-center mb-8">
                    <h2 class="text-3xl font-bold text-gray-900">Roles Management</h2>
                    <button phx-click="new" class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500">
                      New Role
                    </button>
                  </div>

                  <div class="mb-6">
                    <form phx-change="search" class="flex gap-4">
                      <input
                        type="text"
                        name="search"
                        placeholder="Search Users..."
                        class="flex-1 px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                        value={@search_term}
                      />
                    </form>
                  </div>

                  <div class=" overflow-x-auto">
                    <table class="space-y-12 divide-y divide-gray-200">
                      <thead class="bg-gray-50">
                        <tr>
                          <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">first name</th>
                          <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">last name</th>
                          <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">email</th>
                          <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">address</th>
                          <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">phone number</th>

                          <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                        </tr>
                      </thead>
                      <tbody class="bg-white divide-y divide-gray-200">
                        <%= for user <- @users do %>
                          <tr>
                            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                              <%= user.first_name %>
                            </td>

                            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                              <%= user.last_name %>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                              <%= user.email %>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                              <%= user.address %>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                              <%= user.phone_number %>
                            </td>


                            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                              <%= user.subscribed %>
                            </td>

                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                              <span class={"px-2 py-1 rounded-full text-xs #{if user.active, do: "bg-green-100 text-green-800", else: "bg-red-100 text-red-800"}"}>
                                <%= if user.active, do: "Active", else: "Inactive" %>
                              </span>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                              <div class="flex space-x-2">
                                <button phx-click="edit" phx-value-id={user.id} class="text-indigo-600 hover:text-indigo-900">
                                  Edit
                                </button>
                                <button phx-click="delete" phx-value-id={user.id} data-confirm="Are you sure?" class="text-red-600 hover:text-red-900">
                                  Delete
                                </button>
                              </div>
                            </td>
                          </tr>
                        <% end %>
                      </tbody>
                    </table>
                  </div>
                </div>
              </div>
            <%!-- </div> --%>
          <%!-- </div> --%>
        </div>

        <%= if @show_modal do %>
          <div class="fixed z-10 inset-0 overflow-y-auto" aria-labelledby="modal-title" user="dialog" aria-modal="true">
            <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
              <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" aria-hidden="true"></div>

              <div class="inline-block align-bottom bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full">
                <.simple_form for={@form} id="user-form" phx-submit="save" class="space-y-6 p-6">
                  <.input field={@form[:first_name]} type="text" label="first name" required />
                  <.input field={@form[:last_name]} type="text" label="last name" required />
                  <.input field={@form[:email]} type="text" label="email" required />
                  <.input field={@form[:phone_number]} type="text" label="phone number" required />
                  <.input field={@form[:address]} type="text" label="address" required />
                  <.input field={@form[:password]} type="text" label="password" required />

                  <.input
                    field={@form[:active]}
                    type="checkbox"
                    label="Active"
                  />

                  <div class="mt-5 sm:mt-6 flex justify-end space-x-3">
                    <button type="button" phx-click="close_modal" class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
                      Cancel
                    </button>
                    <button type="submit" class="px-4 py-2 text-sm font-medium text-white bg-blue-600 border border-transparent rounded-md shadow-sm hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
                      Save
                    </button>
                  </div>
                </.simple_form>
              </div>
            </div>
          </div>
        <% end %>
      </div>
      """
    end

    @impl true
    def handle_event("search", %{"search" => search_term}, socket) do
      users =
        from(r in User)
        |> where([r], ilike(r.first_name, ^"%#{search_term}%") or ilike(r.phone_number, ^"%#{search_term}%"))
        |> Repo.all()

      {:noreply, assign(socket, users: users, search_term: search_term)}
    end

    @impl true
    def handle_event("save", %{"users" => role_params}, socket) do
      # Convert comma-separated first_name string to list
      role_params = Map.update(role_params, "first_name", [], fn first_name_string ->
        String.split(first_name_string, ",")
        |> Enum.map(&String.trim/1)
        |> Enum.reject(&(&1 == ""))
      end)

      case create_or_update_role(socket.assigns.editing_role, role_params) do
        {:ok, _role} ->
          {:noreply,
           socket
           |> put_flash(:info, "User saved successfully")
           |> assign(show_modal: false, editing_role: nil)
           |> assign(roles: list_users())}

        {:error, changeset} ->
          {:noreply, assign_form(socket, changeset)}
      end
    end

    @impl true
    def handle_event("delete", %{"id" => id}, socket) do
      user = Repo.get!(Roles, id)
      {:ok, _} = Repo.delete(user)

      {:noreply,
       socket
       |> put_flash(:info, "Role deleted successfully")
       |> assign(roles: list_users())}
    end

    @impl true
    def handle_event("edit", %{"id" => id}, socket) do
      user = Repo.get!(Roles, id)
      changeset = Roles.changeset(user, %{})

      {:noreply,
       socket
       |> assign(editing_role: user)
       |> assign_form(changeset)
       |> assign(show_modal: true)}
    end

    @impl true
    def handle_event("new", _params, socket) do
      {:noreply,
       socket
       |> assign(editing_role: nil)
       |> assign_form(User.registration_changeset(%User{}, %{}))
       |> assign(show_modal: true)}
    end

    @impl true
    def handle_event("close_modal", _, socket) do
      {:noreply, assign(socket, show_modal: false)}
    end

    defp list_users do
      Repo.all(from r in User, order_by: [desc: r.inserted_at])
    end

    defp create_or_update_role(nil, role_params) do
      %User{}
      |> User.registration_changeset(role_params)
      |> Repo.insert()
    end

    defp create_or_update_role(user, role_params) do
      user
      |> User.registration_changeset(role_params)
      |> Repo.update()
    end

    defp assign_form(socket, %Ecto.Changeset{} = changeset) do
      assign(socket, :form, to_form(changeset))
    end
  end
