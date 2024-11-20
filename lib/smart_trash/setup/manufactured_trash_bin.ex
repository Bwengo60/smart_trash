defmodule SmartTrash.Setup.ManufacturedTrashBin do
  alias SmartTrash.Database.Context.TrashBinContext
  def process do
    [
      %{
        mac_address: "84:CC:A8:A3:CD:9B",
        trash_code: "3766",
        active: true
      }
    ]
    |> Enum.map(fn data ->
      TrashBinContext.create_man_trash(data)
    end)
  end
end
