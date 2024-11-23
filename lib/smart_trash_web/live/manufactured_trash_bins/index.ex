defmodule SmartTrashWeb.ManufacturedTrashBins.Index do
    use SmartTrashWeb, :live_view
    alias SmartTrash.Database.Schema.ManufacturedTrashBin
    alias SmartTrash.Repo
    import Ecto.Query
    alias SmartTrash.Accounts

    @impl true
    def mount(_params, session, socket) do
      trash = list_trash_bins()

      user = Accounts.User
           |> preload(:role)
           |> Repo.get!(Accounts.get_user_by_session_token(session["user_token"]).id)

      socket = socket
        |> assign(:page_title, "ManufacturedTrashBin Management")
        |> assign(:trash, trash)
        |> assign(:search_term, "")
        |> assign(:show_modal, false)
        |> assign(:show_details_modal, false)
        |> assign(:selected_trash, nil)
        |> assign(:editing_user, nil)
        |> assign(:current_user, user)
        |> assign_form(ManufacturedTrashBin.changeset(%ManufacturedTrashBin{}, %{}))

      {:ok, socket}
    end

    @impl true
    def render(assigns) do
      ~H"""
      <div class="space-y-12 divide-y">
        <div class="max-w-4xl mx-auto">
          <div class="space-y-12 divide-y divide-gray-200">
            <div class="py-8 text-base leading-6 space-y-4 text-gray-700 sm:text-lg sm:leading-7">
              <div class="flex justify-between items-center mb-8">
                <h2 class="text-3xl font-bold text-gray-900">Manufactured Trash Bins</h2>
                <button phx-click="new" class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500">
                  New Trash Bin
                </button>
              </div>

              <div class="mb-6">
                <form phx-change="search" class="flex gap-4">
                  <input
                    type="text"
                    name="search"
                    placeholder="Search ManufacturedTrashBin Bins..."
                    class="flex-1 px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    value={@search_term}
                  />
                </form>
              </div>

              <div class="overflow-x-auto">
                <table class="min-w-full divide-y divide-gray-200">
                  <thead class="bg-gray-50">
                    <tr>
                      <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Trash Code</th>
                      <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Mac Address</th>
                      <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">status</th>
                      <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                    </tr>
                  </thead>
                  <tbody class="bg-white divide-y divide-gray-200">
                    <%= for user <- @trash do %>
                      <tr>
                        <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                          <%= user.trash_code %>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                          <%= user.mac_address %>
                        </td>

                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                          <span class={"px-2 py-1 rounded-full text-xs #{if user.active, do: "bg-green-100 text-green-800", else: "bg-red-100 text-red-800"}"}>
                            <%= if user.active, do: "Active", else: "Inactive" %>
                          </span>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                          <div class="flex space-x-2">
                            <button phx-click="show" phx-value-id={user.id} class="text-blue-600 hover:text-blue-900">
                              Show
                            </button>
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
        </div>

        <%= if @show_modal do %>
          <div class="fixed z-10 inset-0 overflow-y-auto" aria-labelledby="modal-title" role="dialog" aria-modal="true">
            <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
              <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" aria-hidden="true"></div>

              <div class="inline-block align-bottom bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full">
                <.form for={@form} id="user-form" phx-submit="save" class="space-y-6 p-6">
                  <.input field={@form[:trash_code]} type="text" label="ManufacturedTrashBin Code" required />
                  <.input field={@form[:mac_address]} type="text" label="Mac Address" required />


                  <.input field={@form[:active]} type="checkbox" label="Active" />

                  <div class="mt-5 sm:mt-6 flex justify-end space-x-3">
                    <button type="button" phx-click="close_modal" class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
                      Cancel
                    </button>
                    <button type="submit" class="px-4 py-2 text-sm font-medium text-white bg-blue-600 border border-transparent rounded-md shadow-sm hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
                      Save
                    </button>
                  </div>
                </.form>
              </div>
            </div>
          </div>
        <% end %>

        <%= if @show_details_modal do %>
          <div class="fixed z-10 inset-0 overflow-y-auto" aria-labelledby="modal-title" role="dialog" aria-modal="true">
            <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
              <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" aria-hidden="true"></div>

              <div class="inline-block align-bottom bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full">
                <div class="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
                  <h3 class="text-lg leading-6 font-medium text-gray-900 mb-4">Manufactured Trash Bin Details</h3>
                  <%= if @selected_trash do %>
                    <dl class="grid grid-cols-1 gap-x-4 gap-y-6 sm:grid-cols-2">
                      <div class="sm:col-span-1">
                        <dt class="text-sm font-medium text-gray-500">Trash Code</dt>
                        <dd class="mt-1 text-sm text-gray-900"><%= @selected_trash.trash_code %></dd>
                      </div>
                      <div class="sm:col-span-1">
                        <dt class="text-sm font-medium text-gray-500">Mac Address</dt>
                        <dd class="mt-1 text-sm text-gray-900"><%= @selected_trash.mac_address %></dd>
                      </div>

                      <div class="sm:col-span-1">
                        <dt class="text-sm font-medium text-gray-500">Status</dt>
                        <dd class="mt-1 text-sm text-gray-900"><%= if @selected_trash.active, do: "Active", else: "Inactive" %></dd>
                      </div>
                    </dl>
                  <% end %>
                </div>
                <div class="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
                  <button type="button" phx-click="close_details_modal" class="mt-3 w-full inline-flex justify-center rounded-md border border-gray-300 shadow-sm px-4 py-2 bg-white text-base font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm">
                    Close
                  </button>
                </div>
              </div>
            </div>
          </div>
        <% end %>
      </div>
      """
    end

    @impl true
    def handle_event("search", %{"search" => search_term}, socket) do
      trash =
        from(u in ManufacturedTrashBin)
        |> where([u], ilike(u.trash_code, ^"%#{search_term}%") or
                       ilike(u.mac_address, ^"%#{search_term}%"))
        |> Repo.all()

      {:noreply, assign(socket, trash: trash, search_term: search_term)}
    end

    @impl true
    def handle_event("save", %{"manufactured_trash_bin" => trash_params}, socket) do
      IO.inspect(label: "yyyy")
      case create_update_trash(socket.assigns.editing_user, trash_params) do
        {:ok, _user} ->
          {:noreply,
           socket
           |> put_flash(:info, "ManufacturedTrashBin saved successfully")
           |> assign(show_modal: false, editing_user: nil)
           |> assign(trash: list_trash_bins())}

        {:error, changeset} ->
          {:noreply, assign_form(socket, changeset)}
      end
    end

    @impl true
    def handle_event("delete", %{"id" => id}, socket) do
      user = Repo.get!(ManufacturedTrashBin, id)
      {:ok, _} = Repo.delete(user)

      {:noreply,
       socket
       |> put_flash(:info, "ManufacturedTrashBin deleted successfully")
       |> assign(trash: list_trash_bins())}
    end

    @impl true
    def handle_event("edit", %{"id" => id}, socket) do
      user = Repo.get!(ManufacturedTrashBin, id)
      changeset = ManufacturedTrashBin.changeset(user, %{})

      {:noreply,
       socket
       |> assign(editing_user: user)
       |> assign_form(changeset)
       |> assign(show_modal: true)}
    end

    @impl true
    def handle_event("show", %{"id" => id}, socket) do
      user = Repo.get!(ManufacturedTrashBin, id)

      {:noreply,
       socket
       |> assign(selected_trash: user)
       |> assign(show_details_modal: true)}
    end

    @impl true
    def handle_event("new", _params, socket) do
      {:noreply,
       socket
       |> assign(editing_user: nil)
       |> assign_form(ManufacturedTrashBin.changeset(%ManufacturedTrashBin{}, %{}))
       |> assign(show_modal: true)}
    end

    @impl true
    def handle_event("close_modal", _, socket) do
      {:noreply, assign(socket, show_modal: false)}
    end

    @impl true
    def handle_event("close_details_modal", _, socket) do
      {:noreply, assign(socket, show_details_modal: false)}
    end

    defp list_trash_bins do
      ManufacturedTrashBin
      |> order_by([desc: :inserted_at])
      |> Repo.all()
    end

    defp create_update_trash(nil, user_params) do
      %ManufacturedTrashBin{}
      |> ManufacturedTrashBin.changeset(user_params)
      |> Repo.insert()
    end

    defp create_update_trash(user, user_params) do
      user
      |> ManufacturedTrashBin.changeset(user_params)
      |> Repo.update()
    end

    defp assign_form(socket, %Ecto.Changeset{} = changeset) do
      assign(socket, :form, to_form(changeset))
    end
  end
