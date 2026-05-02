defmodule FeitenWeb.SensorsJSON do
  alias Feiten.Sensors.Sensor

  def index(%{sensors: sensors}), do: Enum.map(sensors, &data/1)
  def show(%{sensor: sensor}), do: data(sensor)

  defp data(%Sensor{} = sensor) do
    %{
      id: sensor.id,
      name: sensor.name,
      serialno: sensor.serialno,
      description: sensor.description,
      inserted_at: sensor.inserted_at,
      updated_at: sensor.updated_at
    }
  end
end
