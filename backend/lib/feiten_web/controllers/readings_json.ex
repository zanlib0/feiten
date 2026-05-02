defmodule FeitenWeb.ReadingsJSON do
  import Decimal

  alias Feiten.Sensors.Reading

  def index(%{readings: readings}) do
    readings |> Enum.map(&data/1)
  end

  defp data(%Reading{} = reading) do
    %{
      time: reading.time,
      serialno: reading.serialno,
      pm1: reading.pm1 |> to_float(),
      pm2: reading.pm2 |> to_float(),
      pm10: reading.pm10 |> to_float(),
      temperature: reading.temperature |> to_float(),
      humidity: reading.humidity |> to_float(),
      voc: reading.voc |> to_float(),
      nox: reading.nox |> to_float(),
      co2: reading.co2 |> to_float()
    }
  end
end
