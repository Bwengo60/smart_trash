defmodule SmartTrash.Repo.Migrations.CreateUsersAuthTables do
  use Ecto.Migration

  def change do
    # execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:roles_table) do
      add :group, :string
      add :permissions, {:array, :string}, default: []
      add :active, :boolean
      timestamps()
    end



    create table(:users_table) do
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :username, :string, null: false
      add :email, :citext, null: false
      add :phone_number, :string, null: false
      add :address, :string, null: false
      add :active, :boolean, null: false, default: true
      add :hashed_password, :string, null: false
      add :confirmed_at, :utc_datetime
      add :subscribed, :boolean
      add :user_type, :string
      add :role_id, references(:roles_table, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users_table, [:email])

    create table(:users_tokens) do
      add :user_id, references(:users_table, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:context, :token])

    create table(:trash_table) do
      add :trash_code, :string
      add :trash_levels, :integer
      add :active, :boolean, null: true
      add :collected, :boolean, default: true
      add :user_id, references(:users_table, on_delete: :delete_all)


      timestamps()
    end

    create table(:manufactured_trash_bins) do
      add :mac_address, :string
      add :trash_code, :string
      add :active, :boolean, default: true
      timestamps()
    end

    create table(:subscription_packages) do
      add :name, :string
      add :description, :string
      add :amount, :integer
      add :type, :string
      add :active, :boolean, default: true

      timestamps()
    end

    create table(:subscriptions_table)do
      add :subscription_due, :naive_datetime
      add :status, :string
      add :user_id, references(:users_table, on_delete: :delete_all), null: false
      add :subscription_package_id, references(:subscription_packages, on_delete: :delete_all), null: false
      timestamps()
    end


  end
end
