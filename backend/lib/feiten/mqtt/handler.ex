defmodule Feiten.Mqtt.Handler do
  @moduledoc """
  Tortoise311 handler that decodes AirGradient reading payloads and persists
  them to the `readings` hypertable.
  """

  use Tortoise311.Handler

  alias Feiten.Repo
  alias Feiten.Sensors.Reading

  require Logger

  @impl true
  def init(_opts), do: {:ok, %{}}

  @impl true
  def connection(status, state) do
    Logger.info("MQTT connection: #{status}")
    {:ok, state}
  end

  @impl true
  def subscription(status, topic_filter, state) do
    Logger.info("MQTT subscription #{inspect(topic_filter)}: #{status}")
    {:ok, state}
  end

  @impl true
  def handle_message(topic, payload, state) do
    parse_and_insert(topic, payload)
    {:ok, state}
  end

  @impl true
  def terminate(_reason, _state), do: :ok

  @doc """
  Decode `payload` and insert a `Reading` row keyed off the trailing topic
  segment. Errors are logged and dropped (we ack-and-drop bad payloads).
  """
  def parse_and_insert(topic, payload) do
    serialno = topic |> List.last() |> to_string()

    with {:ok, decoded} <- Jason.decode(payload),
         _ <- maybe_warn_serial_mismatch(serialno, decoded) do
      attrs = %{
        time: DateTime.utc_now() |> DateTime.truncate(:second),
        serialno: serialno,
        pm1: decoded["pm01"],
        pm2: decoded["pm02"],
        pm10: decoded["pm10"],
        temperature: decoded["atmpCompensated"],
        humidity: decoded["rhumCompensated"],
        voc: decoded["tvocIndex"],
        nox: decoded["noxIndex"],
        co2: decoded["rco2"]
      }

      %Reading{}
      |> Reading.changeset(attrs)
      |> Repo.insert()
      |> case do
        {:ok, _reading} ->
          :ok

        {:error, changeset} ->
          Logger.warning(
            "Dropping reading for #{serialno}: #{inspect(changeset.errors)}"
          )

          :ok
      end
    else
      {:error, %Jason.DecodeError{} = err} ->
        Logger.warning("Dropping unparseable MQTT payload on #{inspect(topic)}: #{inspect(err)}")
        :ok
    end
  end

  defp maybe_warn_serial_mismatch(topic_serial, %{"serialno" => payload_serial})
       when is_binary(payload_serial) and payload_serial != topic_serial do
    Logger.warning(
      "MQTT payload serialno=#{payload_serial} does not match topic #{topic_serial}; using topic"
    )

    :ok
  end

  defp maybe_warn_serial_mismatch(_topic_serial, _decoded), do: :ok
end
