defmodule SmartTrashWeb.UserRoles.IndexLive do

    use SmartTrashWeb, :live_view
    alias SmartTrash.Database.Schema.Roles
    alias SmartTrash.Repo
    import Ecto.Query

    @impl true
    def mount(_params, _session, socket) do
      roles = list_roles()

      socket = socket
        |> assign(:page_title, "Roles Management")
        |> assign(:roles, roles)
        |> assign(:search_term, "")
        |> assign(:show_modal, false)
        |> assign(:editing_role, nil)
        |> assign_form(Roles.changeset(%Roles{}, %{}))

      {:ok, socket}
    end

    @impl true
    def render(assigns) do
      ~H"""
      <div class="space-y-12 divide-y">
        <%!-- <div class="relative py-3 sm:max-w-5xl sm:mx-auto"> --%>
          <div class="relative px-4 py-10 bg-white shadow-lg sm:rounded-3xl sm:p-20">
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
                        placeholder="Search roles..."
                        class="flex-1 px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                        value={@search_term}
                      />
                    </form>
                  </div>

                  <div class=" overflow-x-auto">
                    <table class="space-y-12 divide-y divide-gray-200">
                      <thead class="bg-gray-50">
                        <tr>
                          <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Group</th>
                          <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Permissions</th>
                          <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                          <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                        </tr>
                      </thead>
                      <tbody class="bg-white divide-y divide-gray-200">
                        <%= for role <- @roles do %>
                          <tr>
                            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                              <%= role.group %>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                              <div class="flex flex-wrap gap-2">
                                <%= for permission <- role.permissions do %>
                                  <span class="px-2 py-1 bg-blue-100 text-blue-800 rounded-full text-xs">
                                    <%= permission %>
                                  </span>
                                <% end %>
                              </div>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                              <span class={"px-2 py-1 rounded-full text-xs #{if role.active, do: "bg-green-100 text-green-800", else: "bg-red-100 text-red-800"}"}>
                                <%= if role.active, do: "Active", else: "Inactive" %>
                              </span>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                              <div class="flex space-x-2">
                                <button phx-click="edit" phx-value-id={role.id} class="text-indigo-600 hover:text-indigo-900">
                                  Edit
                                </button>
                                <button phx-click="delete" phx-value-id={role.id} data-confirm="Are you sure?" class="text-red-600 hover:text-red-900">
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
            </div>
          <%!-- </div> --%>
        </div>

        <%= if @show_modal do %>
          <div class="fixed z-10 inset-0 overflow-y-auto" aria-labelledby="modal-title" role="dialog" aria-modal="true">
            <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
              <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" aria-hidden="true"></div>

              <div class="inline-block align-bottom bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full">
                <.simple_form for={@form} id="role-form" phx-submit="save" class="space-y-6 p-6">
                  <.input field={@form[:group]} type="text" label="Group" required />

                  <.input
                    field={@form[:permissions]}
                    type="text"
                    label="Permissions (comma-separated)"
                    value={Enum.join(@form[:permissions].value || [], ", ")}
                  />

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
      roles =
        from(r in Roles)
        |> where([r], ilike(r.group, ^"%#{search_term}%"))
        |> Repo.all()

      {:noreply, assign(socket, roles: roles, search_term: search_term)}
    end

    @impl true
    def handle_event("save", %{"roles" => role_params}, socket) do
      # Convert comma-separated permissions string to list
      role_params = Map.update(role_params, "permissions", [], fn permissions_string ->
        String.split(permissions_string, ",")
        |> Enum.map(&String.trim/1)
        |> Enum.reject(&(&1 == ""))
      end)

      case create_or_update_role(socket.assigns.editing_role, role_params) do
        {:ok, _role} ->
          {:noreply,
           socket
           |> put_flash(:info, "Role saved successfully")
           |> assign(show_modal: false, editing_role: nil)
           |> assign(roles: list_roles())}

        {:error, changeset} ->
          {:noreply, assign_form(socket, changeset)}
      end
    end

    @impl true
    def handle_event("delete", %{"id" => id}, socket) do
      role = Repo.get!(Roles, id)
      {:ok, _} = Repo.delete(role)

      {:noreply,
       socket
       |> put_flash(:info, "Role deleted successfully")
       |> assign(roles: list_roles())}
    end

    @impl true
    def handle_event("edit", %{"id" => id}, socket) do
      role = Repo.get!(Roles, id)
      changeset = Roles.changeset(role, %{})

      {:noreply,
       socket
       |> assign(editing_role: role)
       |> assign_form(changeset)
       |> assign(show_modal: true)}
    end

    @impl true
    def handle_event("new", _params, socket) do
      {:noreply,
       socket
       |> assign(editing_role: nil)
       |> assign_form(Roles.changeset(%Roles{}, %{}))
       |> assign(show_modal: true)}
    end

    @impl true
    def handle_event("close_modal", _, socket) do
      {:noreply, assign(socket, show_modal: false)}
    end

    defp list_roles do
      Repo.all(from r in Roles, order_by: [desc: r.inserted_at])
    end

    defp create_or_update_role(nil, role_params) do
      %Roles{}
      |> Roles.changeset(role_params)
      |> Repo.insert()
    end

    defp create_or_update_role(role, role_params) do
      role
      |> Roles.changeset(role_params)
      |> Repo.update()
    end

    defp assign_form(socket, %Ecto.Changeset{} = changeset) do
      assign(socket, :form, to_form(changeset))
    end
  end
