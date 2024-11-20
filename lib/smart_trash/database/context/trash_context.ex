defmodule SmartTrash.Database.Context.TrashContext do
  alias SmartTrash.Database.Schema.Trash
  alias SmartTrash.Repo
  import Ecto.Query

  def create_trash_bin(attrs) do
    %Trash{}
    |> Trash.changeset(attrs)
    |> Repo.insert()
  end

  def list_trash_bins do
    Trash
    |> Repo.all()
  end

  def list_active_trash_bins do
    Trash
    |> where([a], a.active == true)
    |> Repo.all()
  end

  def list_trash_by_user(id) do
    Trash
    |> preload(:user)
    |> where([a], a.user_id==^id)
    |> Repo.all()
  end

end
