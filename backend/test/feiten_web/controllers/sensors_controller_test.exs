defmodule FeitenWeb.SensorsControllerTest do
  use FeitenWeb.ConnCase, async: true

  import Ecto.Query

  alias Feiten.Mqtt.AuthAcl
  alias Feiten.Repo
  alias Feiten.Sensors.Reading
  alias Feiten.Sensors.Sensor

  defp insert_sensor!(attrs) do
    %Sensor{}
    |> Sensor.changeset(attrs)
    |> Repo.insert!()
  end

  describe "GET /api/sensors" do
    test "returns an empty list when no sensors exist", %{conn: conn} do
      conn = get(conn, ~p"/api/sensors")
      assert json_response(conn, 200) == []
    end

    test "returns all sensors", %{conn: conn} do
      sensor =
        insert_sensor!(%{name: "Living Room", serialno: "abc123", description: "Near window"})

      conn = get(conn, ~p"/api/sensors")
      assert [data] = json_response(conn, 200)

      assert data["id"] == sensor.id
      assert data["name"] == "Living Room"
      assert data["serialno"] == "abc123"
      assert data["description"] == "Near window"
      assert data["inserted_at"]
      assert data["updated_at"]
    end
  end

  describe "POST /api/sensors" do
    test "creates the sensor and provisions an MQTT auth row", %{conn: conn} do
      attrs = %{name: "Office", serialno: "80f1b26895f8"}

      conn = post(conn, ~p"/api/sensors", %{"data" => attrs})
      assert data = json_response(conn, 201)

      assert data["name"] == "Office"
      assert data["serialno"] == "80f1b26895f8"
      assert is_binary(data["mqtt_password"])
      assert String.length(data["mqtt_password"]) == 24
      assert data["mqtt_password"] =~ ~r/^[A-Z2-7]+$/

      assert data["mqtt_broker_url"] =~
               ~r/^mqtt:\/\/80f1b26895f8:[A-Z2-7]+@[^:]+:\d+$/

      acl = Repo.get_by(AuthAcl, username: "80f1b26895f8")
      assert acl
      assert acl.client_id == "ESP32_6895F8"
      assert is_binary(acl.password)
      assert acl.publish_acl == [%{"pattern" => "airgradient/readings/80f1b26895f8"}]
    end
  end

  describe "DELETE /api/sensors/:id" do
    test "deletes the sensor and returns 204", %{conn: conn} do
      sensor = insert_sensor!(%{name: "Bedroom", serialno: "xyz789"})

      conn = delete(conn, ~p"/api/sensors/#{sensor.id}")
      assert response(conn, 204) == ""

      assert Repo.get(Sensor, sensor.id) == nil
    end

    test "deletes the matching auth row but preserves readings", %{conn: conn} do
      {:ok, sensor} =
        Feiten.Sensors.create_sensor(%{name: "Hallway", serialno: "deadbeef0001"})

      reading_attrs = %{
        time: DateTime.utc_now() |> DateTime.truncate(:second),
        serialno: "deadbeef0001",
        pm1: 1,
        pm2: 1,
        pm10: 1,
        temperature: 20,
        humidity: 50,
        voc: 100,
        nox: 1,
        co2: 400
      }

      %Reading{}
      |> Reading.changeset(reading_attrs)
      |> Repo.insert!()

      conn = delete(conn, ~p"/api/sensors/#{sensor.id}")
      assert response(conn, 204) == ""

      assert Repo.get_by(AuthAcl, username: "deadbeef0001") == nil

      readings_count =
        Repo.aggregate(
          from(r in Reading, where: r.serialno == ^"deadbeef0001"),
          :count
        )

      assert readings_count == 1
    end

    test "returns 404 when the sensor does not exist", %{conn: conn} do
      conn = delete(conn, ~p"/api/sensors/9999")
      assert json_response(conn, 404) == %{"errors" => %{"detail" => "Not Found"}}
    end
  end
end
