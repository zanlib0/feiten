defmodule Feiten.Sensors do
  import Ecto.Query

  alias Feiten.Repo
  alias Feiten.Sensors.Reading
  alias Feiten.Sensors.Sensor

  def get_readings() do
    one_hour_before = DateTime.now!("Etc/UTC") |> DateTime.add(-1, :hour)

    from(r in Reading, where: r.time > ^one_hour_before)
    |> Repo.all()
  end

  def list_sensors() do
    Repo.all(Sensor)
  end

  def delete_sensor(id) do
    case Repo.get(Sensor, id) do
      nil -> {:error, :not_found}
      sensor -> Repo.delete(sensor)
    end
  end
end
