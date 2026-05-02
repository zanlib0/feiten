defmodule Feiten.Sensors do
  import Ecto.Query

  alias Feiten.Repo
  alias Feiten.Sensors.Reading
  alias Feiten.Sensors.Sensor

  @ranges %{
    "hour" => {3_600, 60},
    "day" => {86_400, 300},
    "week" => {604_800, 1_800},
    "month" => {2_592_000, 7_200}
  }

  def get_readings(range \\ "hour") do
    {seconds, bucket_seconds} = Map.get(@ranges, range, @ranges["hour"])
    start_time = DateTime.now!("Etc/UTC") |> DateTime.add(-seconds, :second)
    bucket = %Postgrex.Interval{secs: bucket_seconds}

    from(r in Reading,
      where: r.time > ^start_time,
      group_by: [selected_as(:bucket), r.serialno],
      order_by: [asc: selected_as(:bucket)],
      select: %{
        time: selected_as(fragment("time_bucket(?, ?)", ^bucket, r.time), :bucket),
        serialno: r.serialno,
        pm1: avg(r.pm1),
        pm2: avg(r.pm2),
        pm10: avg(r.pm10),
        temperature: avg(r.temperature),
        humidity: avg(r.humidity),
        voc: avg(r.voc),
        nox: avg(r.nox),
        co2: avg(r.co2)
      }
    )
    |> Repo.all()
  end

  def list_sensors() do
    Repo.all(Sensor)
  end

  def create_sensor(attrs) do
    %Sensor{}
    |> Sensor.changeset(attrs)
    |> Repo.insert()
  end

  def delete_sensor(id) do
    case Repo.get(Sensor, id) do
      nil -> {:error, :not_found}
      sensor -> Repo.delete(sensor)
    end
  end
end
