defmodule Feiten.Repo.Migrations.AddSensorsTable do
  use Ecto.Migration

  def change do
    create table "sensors" do
      add :name, :string, null: false
      add :serialno, :string, null: false
      add :description, :string

      timestamps()
    end
  end
end
