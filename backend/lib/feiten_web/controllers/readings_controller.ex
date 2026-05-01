defmodule FeitenWeb.ReadingsController do
  use FeitenWeb, :controller

  def index(conn, _params) do
    readings = Feiten.Sensors.get_readings()
    render(conn, :index, readings: readings)
  end
end
