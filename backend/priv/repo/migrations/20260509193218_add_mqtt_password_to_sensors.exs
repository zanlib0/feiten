defmodule Feiten.Repo.Migrations.AddMqttPasswordToSensors do
  use Ecto.Migration

  def change do
    alter table(:sensors) do
      add :mqtt_password, :string
    end
  end
end
