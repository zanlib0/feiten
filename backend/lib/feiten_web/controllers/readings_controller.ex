defmodule FeitenWeb.ReadingsController do
  use FeitenWeb, :controller

  def index(conn, params) do
    readings = Feiten.Sensors.get_readings(params["range"] || "hour")
    render(conn, :index, readings: readings)
  end
end
