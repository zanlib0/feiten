defmodule Feiten.Repo.Migrations.CreateVmqAuthAcl do
  use Ecto.Migration

  def up do
    execute("CREATE EXTENSION IF NOT EXISTS pgcrypto")

    create table(:vmq_auth_acl, primary_key: false) do
      add :mountpoint, :string, size: 10, null: false, default: ""
      add :client_id, :string, size: 128, null: false
      add :username, :string, size: 128, null: false
      add :password, :string, size: 128
      add :publish_acl, :map
      add :subscribe_acl, :map
    end  

    create unique_index(:vmq_auth_acl, [:mountpoint, :client_id, :username],
      name: :vmq_auth_acl_pk)
  end

  def down do
    drop table(:vmq_auth_acl)

    execute("DROP EXTENSION IF EXISTS pgcrypto")
  end
end
