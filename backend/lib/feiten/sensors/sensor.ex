defmodule Feiten.Sensors.Sensor do
  use Ecto.Schema

  import Ecto.Changeset

  schema "sensors" do
    field :name, :string
    field :serialno, :string
    field :description, :string

    timestamps()
  end

  def changeset(sensor, attrs \\ %{}) do
    sensor
    |> cast(attrs, [:name, :serialno, :description])
    |> validate_required([:name, :serialno])
  end
end
