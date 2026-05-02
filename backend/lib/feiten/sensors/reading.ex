defmodule Feiten.Sensors.Reading do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @required_fields [
    :time,
    :serialno,
    :pm1,
    :pm2,
    :pm10,
    :temperature,
    :humidity,
    :voc,
    :nox,
    :co2
  ]

  schema "readings" do
    field :time, :naive_datetime
    field :serialno, :string
    field :pm1, :decimal
    field :pm2, :decimal
    field :pm10, :decimal
    field :temperature, :decimal
    field :humidity, :decimal
    field :voc, :decimal
    field :nox, :decimal
    field :co2, :decimal

    timestamps()
  end

  def changeset(reading, attrs \\ %{}) do
    reading
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
