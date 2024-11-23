defmodule SmartTrashWeb.Compoments.Charts do
    @moduledoc """
    Holds the charts components
    """
    use Phoenix.Component

    attr :id, :string, required: true
    def line_graph(assigns) do
      ~H"""
      <div
        id={@id}
        phx-hook="Chart"
      ></div>
      """
    end
end
