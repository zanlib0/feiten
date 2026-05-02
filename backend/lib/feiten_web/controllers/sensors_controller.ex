defmodule FeitenWeb.SensorsController do
  use FeitenWeb, :controller

  alias Feiten.Repo
  alias Feiten.Sensors.Sensor

  def post(conn, %{"data" => data}) do
    %Sensor{}
    |> Sensor.changeset(data)
    |> Repo.insert()

    resp(conn, :ok, "ok")
  end

  def index(conn, _params) do
    sensors = Feiten.Sensors.list_sensors()
    render(conn, :index, sensors: sensors)
  end

  def delete(conn, %{"id" => id}) do
    case Feiten.Sensors.delete_sensor(id) do
      {:ok, _sensor} -> send_resp(conn, :no_content, "")
      {:error, :not_found} -> send_resp(conn, :not_found, "")
    end
  end
end
