defmodule Feiten.Sensors.Sensor do
  use Ecto.Schema

  schema "sensors" do
    field :name, :string
    field :serialno, :string
    field :description, :string

    timestamps()
  end
end
