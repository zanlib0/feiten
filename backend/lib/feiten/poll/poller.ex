defmodule Feiten.Poll.Poller do
  import Ecto.Query

  alias Feiten.Repo
  alias Feiten.Sensors.Sensor
  alias Feiten.Sensors.Reading

  def poll do
    from(s in Sensor, select: %{serialno: s.serialno})
    |> Repo.all()
    |> Enum.each(&save_sensor_reading/1)
  end

  defp save_sensor_reading(sensor) do
    {:ok, %{body: reading}} =
      Req.get("http://airgradient_#{sensor.serialno}.local/measures/current")

    attrs = %{
      time: DateTime.now!("Etc/UTC"),
      serialno: sensor.serialno,
      pm1: reading["pm01"],
      pm2: reading["pm02"],
      pm10: reading["pm10"],
      temperature: reading["atmpCompensated"],
      humidity: reading["rhumCompensated"],
      voc: reading["tvocIndex"],
      nox: reading["noxIndex"],
      co2: reading["rco2"]
    }

    %Reading{}
    |> Reading.changeset(attrs)
    |> Repo.insert()
  end
end
