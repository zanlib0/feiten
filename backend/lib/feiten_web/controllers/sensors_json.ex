defmodule FeitenWeb.SensorsJSON do
  alias Feiten.Sensors.Sensor

  def index(%{sensors: sensors}), do: Enum.map(sensors, &data/1)
  def show(%{sensor: sensor}), do: data(sensor)

  defp data(%Sensor{} = sensor) do
    %{
      id: sensor.id,
      name: sensor.name,
      serialno: sensor.serialno,
      description: sensor.description,
      mqtt_password: sensor.mqtt_password,
      mqtt_broker_url: build_broker_url(sensor),
      inserted_at: sensor.inserted_at,
      updated_at: sensor.updated_at
    }
  end

  defp build_broker_url(%Sensor{mqtt_password: nil}), do: nil

  defp build_broker_url(%Sensor{serialno: serialno, mqtt_password: password}) do
    cfg = Application.get_env(:feiten, Feiten.Mqtt, [])
    host = Keyword.get(cfg, :public_host)
    port = Keyword.get(cfg, :public_port)

    if host && port do
      "mqtt://#{serialno}:#{password}@#{host}:#{port}"
    else
      nil
    end
  end
end
