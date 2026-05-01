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
  
end
