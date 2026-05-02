defmodule FeitenWeb.SensorsControllerTest do
  use FeitenWeb.ConnCase, async: true

  alias Feiten.Repo
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

  describe "DELETE /api/sensors/:id" do
    test "deletes the sensor and returns 204", %{conn: conn} do
      sensor = insert_sensor!(%{name: "Bedroom", serialno: "xyz789"})

      conn = delete(conn, ~p"/api/sensors/#{sensor.id}")
      assert response(conn, 204) == ""

      assert Repo.get(Sensor, sensor.id) == nil
    end

    test "returns 404 when the sensor does not exist", %{conn: conn} do
      conn = delete(conn, ~p"/api/sensors/9999")
      assert response(conn, 404) == ""
    end
  end
end
