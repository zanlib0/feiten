defmodule Feiten.Repo do
  use Ecto.Repo,
    otp_app: :feiten,
    adapter: Ecto.Adapters.Postgres
end
