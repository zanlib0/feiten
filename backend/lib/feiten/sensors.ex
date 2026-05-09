defmodule Feiten.Sensors do
  import Ecto.Query

  alias Ecto.Multi
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

    multi =
      Multi.new()
      |> Multi.insert(:sensor, changeset)
      |> Multi.run(:auth_acl, fn repo, %{sensor: sensor} ->
        client_id = client_id_for(sensor.serialno)

        publish_acl = [%{"pattern" => "airgradient/readings/#{sensor.serialno}"}]
        subscribe_acl = []

        repo.query!(
          """
          INSERT INTO vmq_auth_acl
            (mountpoint, client_id, username, password, publish_acl, subscribe_acl)
          VALUES ($1, $2, $3, crypt($4, gen_salt('bf')), $5, $6)
          """,
          [
            "",
            client_id,
            sensor.serialno,
            plaintext,
            publish_acl,
            subscribe_acl
          ]
        )

        {:ok, :inserted}
      end)

    case Repo.transaction(multi) do
      {:ok, %{sensor: sensor}} -> {:ok, sensor}
      {:error, _step, reason, _changes} -> {:error, reason}
    end
  end

  def delete_sensor(id) do
    case Repo.get(Sensor, id) do
      nil ->
        {:error, :not_found}

      sensor ->
        multi =
          Multi.new()
          |> Multi.delete_all(
            :auth_acl,
            from(a in AuthAcl, where: a.username == ^sensor.serialno)
          )
          |> Multi.delete(:sensor, sensor)

        case Repo.transaction(multi) do
          {:ok, %{sensor: sensor}} -> {:ok, sensor}
          {:error, _step, reason, _changes} -> {:error, reason}
        end
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
