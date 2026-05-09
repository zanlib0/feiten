defmodule Feiten.Sensors do
  import Ecto.Query

  alias Feiten.Mqtt.AuthAcl
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
    plaintext = generate_mqtt_password()

    changeset =
      %Sensor{}
      |> Sensor.changeset(attrs)
      |> Ecto.Changeset.put_change(:mqtt_password, plaintext)

    Repo.transact(fn ->
      with {:ok, sensor} <- Repo.insert(changeset) do
        Repo.query!(
          """
          INSERT INTO vmq_auth_acl
            (mountpoint, client_id, username, password, publish_acl, subscribe_acl)
          VALUES ($1, $2, $3, crypt($4, gen_salt('bf')), $5, $6)
          """,
          [
            "",
            client_id_for(sensor.serialno),
            sensor.serialno,
            plaintext,
            [%{"pattern" => "airgradient/readings/#{sensor.serialno}"}],
            []
          ]
        )

        {:ok, sensor}
      end
    end)
  end

  def delete_sensor(id) do
    case Repo.get(Sensor, id) do
      nil ->
        {:error, :not_found}

      sensor ->
        Repo.transact(fn ->
          Repo.delete_all(from a in AuthAcl, where: a.username == ^sensor.serialno)
          Repo.delete(sensor)
        end)
    end
  end

  def client_id_for(serialno) when is_binary(serialno) do
    suffix =
      serialno
      |> String.slice(-6, 6)
      |> String.upcase()

    "ESP32_" <> suffix
  end

  defp generate_mqtt_password do
    :crypto.strong_rand_bytes(15) |> Base.encode32(padding: false)
  end
end
