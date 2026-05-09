defmodule Feiten.Mqtt.HandlerTest do
  use Feiten.DataCase, async: true

  alias Feiten.Mqtt.Handler
  alias Feiten.Sensors.Reading

  test "decodes payload and inserts a reading keyed off the topic serialno" do
    payload =
      Jason.encode!(%{
        "serialno" => "deadbeefcafe",
        "pm01" => 1,
        "pm02" => 2,
        "pm10" => 3,
        "atmpCompensated" => 21,
        "rhumCompensated" => 40,
        "tvocIndex" => 100,
        "noxIndex" => 1,
        "rco2" => 420
      })

    Handler.parse_and_insert(["airgradient", "readings", "deadbeefcafe"], payload)

    [reading] = Repo.all(Reading)
    assert reading.serialno == "deadbeefcafe"
    assert Decimal.equal?(reading.pm1, 1)
    assert Decimal.equal?(reading.co2, 420)
  end

  @tag :capture_log
  test "drops unparseable payloads without raising" do
    assert :ok =
             Handler.parse_and_insert(
               ["airgradient", "readings", "abc"],
               "not-json"
             )

    assert Repo.all(Reading) == []
  end
end
