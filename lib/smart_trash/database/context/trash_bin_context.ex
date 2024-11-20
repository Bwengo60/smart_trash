defmodule SmartTrash.Database.Context.TrashBinContext do
  alias SmartTrash.Database.Schema.ManufacturedTrashBin
  alias SmartTrash.Repo
  import Ecto.Query

  def create_man_trash(attrs) do
    %ManufacturedTrashBin{}
    |> ManufacturedTrashBin.changeset(attrs)
    |> Repo.insert!()
  end

  def list_man_trash do
    ManufacturedTrashBin
    |>Repo.all()
  end

  def get_man_trash_by_code(code) do
    ManufacturedTrashBin
    |> where([a], a.trash_code== ^code)
    |> Repo.one!()
  end

  def list_active_man_trash do
    ManufacturedTrashBin
    |> where([a], a.active== true)
    |> Repo.all()
  end
end
