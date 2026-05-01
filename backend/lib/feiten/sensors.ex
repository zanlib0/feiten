defmodule Feiten.Sensors do
  import Ecto.Query

  alias Feiten.Repo
  alias Feiten.Sensors.Reading

  def get_readings() do
    one_hour_before = DateTime.now!("Etc/UTC") |> DateTime.add(-1, :hour)

    from(r in Reading, where: r.time > ^one_hour_before)
    |> Repo.all()
  end
end
