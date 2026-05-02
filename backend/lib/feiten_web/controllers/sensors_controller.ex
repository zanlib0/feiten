defmodule FeitenWeb.SensorsController do
  use FeitenWeb, :controller

  alias Feiten.Sensors
  alias Feiten.Sensors.Sensor

  action_fallback FeitenWeb.FallbackController

  def index(conn, _params) do
    sensors = Sensors.list_sensors()
    render(conn, :index, sensors: sensors)
  end

  def post(conn, %{"data" => data}) do
    with {:ok, %Sensor{} = sensor} <- Sensors.create_sensor(data) do
      conn
      |> put_status(:created)
      |> render(:show, sensor: sensor)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, _sensor} <- Sensors.delete_sensor(id) do
      send_resp(conn, :no_content, "")
    end
  end
end
