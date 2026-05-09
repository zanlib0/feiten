defmodule Feiten.SensorsTest do
  use Feiten.DataCase, async: true

  alias Feiten.Mqtt.AuthAcl
  alias Feiten.Sensors
  alias Feiten.Sensors.Reading
  alias Feiten.Sensors.Sensor

  describe "create_sensor/1" do
    test "writes both sensor and auth_acl rows in one transaction" do
      {:ok, sensor} =
        Sensors.create_sensor(%{name: "Kitchen", serialno: "abcdef123456"})

      assert is_binary(sensor.mqtt_password)
      assert String.length(sensor.mqtt_password) == 24

      acl = Repo.get_by(AuthAcl, username: "abcdef123456")
      assert acl
      assert acl.client_id == "ESP32_123456"
      assert acl.publish_acl == [%{"pattern" => "airgradient/readings/abcdef123456"}]
      assert acl.subscribe_acl == []
      assert is_binary(acl.password)
      refute acl.password == sensor.mqtt_password
    end

    test "rolls back when sensor changeset is invalid" do
      assert {:error, %Ecto.Changeset{}} = Sensors.create_sensor(%{name: "no serial"})

      assert Repo.aggregate(AuthAcl, :count) == 0
      assert Repo.aggregate(Sensor, :count) == 0
    end
  end

  describe "delete_sensor/1" do
    test "removes the sensor and its auth row, leaves readings intact" do
      {:ok, sensor} = Sensors.create_sensor(%{name: "Den", serialno: "11aabbccddee"})

      reading_attrs = %{
        time: DateTime.utc_now() |> DateTime.truncate(:second),
        serialno: "11aabbccddee",
        pm1: 2,
        pm2: 2,
        pm10: 2,
        temperature: 21,
        humidity: 40,
        voc: 50,
        nox: 1,
        co2: 420
      }

      %Reading{}
      |> Reading.changeset(reading_attrs)
      |> Repo.insert!()

      assert {:ok, _} = Sensors.delete_sensor(sensor.id)

      assert Repo.get(Sensor, sensor.id) == nil
      assert Repo.get_by(AuthAcl, username: "11aabbccddee") == nil

      assert Repo.aggregate(
               from(r in Reading, where: r.serialno == ^"11aabbccddee"),
               :count
             ) == 1
    end

    test "returns :not_found for missing id" do
      assert Sensors.delete_sensor(9_999_999) == {:error, :not_found}
    end
  end

  describe "client_id_for/1" do
    test "uppercases the last six chars" do
      assert Sensors.client_id_for("80f1b26895f8") == "ESP32_6895F8"
      assert Sensors.client_id_for("AbCdEf") == "ESP32_ABCDEF"
    end
  end
end
