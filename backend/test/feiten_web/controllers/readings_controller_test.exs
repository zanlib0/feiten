defmodule FeitenWeb.ReadingsControllerTest do
  use FeitenWeb.ConnCase, async: true

  alias Feiten.Repo
  alias Feiten.Sensors.Reading

  defp insert_reading!(attrs) do
    defaults = %{
      serialno: "abc123",
      pm1: Decimal.new("1.0"),
      pm2: Decimal.new("2.0"),
      pm10: Decimal.new("3.0"),
      temperature: Decimal.new("20.0"),
      humidity: Decimal.new("50.0"),
      voc: Decimal.new("100.0"),
      nox: Decimal.new("1.0"),
      co2: Decimal.new("400.0")
    }

    %Reading{}
    |> Reading.changeset(Map.merge(defaults, attrs))
    |> Repo.insert!()
  end

  defp ago(seconds) do
    NaiveDateTime.utc_now()
    |> NaiveDateTime.add(-seconds, :second)
    |> NaiveDateTime.truncate(:second)
  end

  # Snap to a bucket boundary aligned to the epoch (matches `time_bucket`'s
  # default origin), so `+ delta` (delta < bucket_secs) stays inside the bucket.
  defp ago_bucket_start(seconds, bucket_secs) do
    epoch = ~N[1970-01-01 00:00:00]
    target = NaiveDateTime.diff(NaiveDateTime.utc_now(), epoch, :second) - seconds
    aligned = div(target, bucket_secs) * bucket_secs
    NaiveDateTime.add(epoch, aligned, :second)
  end

  describe "GET /api/readings" do
    test "returns an empty list when there are no readings", %{conn: conn} do
      conn = get(conn, ~p"/api/readings")
      assert json_response(conn, 200) == []
    end

    test "defaults to the last hour and excludes older readings", %{conn: conn} do
      insert_reading!(%{time: ago(60 * 30), pm1: Decimal.new("5.0")})
      insert_reading!(%{time: ago(60 * 60 * 2), pm1: Decimal.new("99.0")})

      conn = get(conn, ~p"/api/readings")
      data = json_response(conn, 200)

      assert length(data) == 1
      assert hd(data)["pm1"] == 5.0
    end

    test "averages readings within the same bucket", %{conn: conn} do
      bucket_time = ago_bucket_start(60 * 10, 60)

      insert_reading!(%{time: bucket_time, pm1: Decimal.new("2.0"), co2: Decimal.new("400.0")})

      insert_reading!(%{
        time: NaiveDateTime.add(bucket_time, 10, :second),
        pm1: Decimal.new("4.0"),
        co2: Decimal.new("600.0")
      })

      conn = get(conn, ~p"/api/readings")
      assert [point] = json_response(conn, 200)

      assert point["pm1"] == 3.0
      assert point["co2"] == 500.0
    end

    test "groups buckets by serialno", %{conn: conn} do
      t = ago(60 * 5)
      insert_reading!(%{time: t, serialno: "sensor-a", pm1: Decimal.new("1.0")})
      insert_reading!(%{time: t, serialno: "sensor-b", pm1: Decimal.new("9.0")})

      conn = get(conn, ~p"/api/readings")
      data = json_response(conn, 200)

      assert length(data) == 2
      assert Enum.sort(Enum.map(data, & &1["serialno"])) == ["sensor-a", "sensor-b"]
    end

    test "returns results in ascending time order", %{conn: conn} do
      insert_reading!(%{time: ago(60 * 5)})
      insert_reading!(%{time: ago(60 * 50)})
      insert_reading!(%{time: ago(60 * 25)})

      conn = get(conn, ~p"/api/readings")
      times = json_response(conn, 200) |> Enum.map(& &1["time"])

      assert times == Enum.sort(times)
    end

    test "range=day uses a 5-minute bucket and includes readings up to a day old", %{conn: conn} do
      bucket_time = ago_bucket_start(60 * 60 * 5, 300)

      insert_reading!(%{time: bucket_time, pm1: Decimal.new("10.0")})

      insert_reading!(%{
        time: NaiveDateTime.add(bucket_time, 60, :second),
        pm1: Decimal.new("20.0")
      })

      insert_reading!(%{time: ago(60 * 60 * 25), pm1: Decimal.new("99.0")})

      conn = get(conn, ~p"/api/readings?range=day")
      data = json_response(conn, 200)

      assert [point] = data
      assert point["pm1"] == 15.0
    end

    test "range=week extends the lookback window beyond a day", %{conn: conn} do
      insert_reading!(%{time: ago(60 * 60 * 24 * 3), pm1: Decimal.new("7.0")})

      conn = get(conn, ~p"/api/readings?range=week")
      assert [point] = json_response(conn, 200)
      assert point["pm1"] == 7.0
    end

    test "an unknown range falls back to the hour default", %{conn: conn} do
      insert_reading!(%{time: ago(60 * 30), pm1: Decimal.new("3.0")})
      insert_reading!(%{time: ago(60 * 60 * 2), pm1: Decimal.new("99.0")})

      conn = get(conn, ~p"/api/readings?range=bogus")
      assert [point] = json_response(conn, 200)
      assert point["pm1"] == 3.0
    end
  end
end
