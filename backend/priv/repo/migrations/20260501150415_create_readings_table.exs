defmodule Feiten.Repo.Migrations.CreateReadingsTable do
  use Ecto.Migration

  def up do
    create table(:readings, primary_key: false) do
      add(:time, :naive_datetime, null: false)
      add(:serialno, :string, null: false)
      add(:pm1, :decimal, null: false)
      add(:pm2, :decimal, null: false)
      add(:pm10, :decimal, null: false)
      add(:temperature, :decimal, null: false)
      add(:humidity, :decimal, null: false)
      add(:voc, :decimal, null: false)
      add(:nox, :decimal, null: false)
      add(:co2, :decimal, null: false)

      timestamps()
    end

    execute("SELECT create_hypertable('readings', 'time')")
  end

  def down do
    drop(table(:readings))
  end
end
