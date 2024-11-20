defmodule SmartTrash.Database.Context.RolesContext do
  alias SmartTrash.Database.Schema.Roles
  import Ecto.Query
  alias SmartTrash.Repo

  def list_roles() do
    Roles
    |>Repo.all()
  end

  def list_active_roles() do
    Roles
    |> where([a], a.active== true)
    |> Repo.all()
  end

  def create_role(attrs) do
    %Roles{}
    |> Roles.changeset(attrs)
    |> Repo.insert()
  end

  def get_role(id) do
    Roles
    |> Repo.get!(id)
  end

  def get_role_by_name(name) do
    Roles
    |> where([a], a.group== ^name)
    |> Repo.one!()
  end
end
