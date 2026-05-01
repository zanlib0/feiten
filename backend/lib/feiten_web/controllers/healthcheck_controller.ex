defmodule FeitenWeb.HealthcheckController do
  use FeitenWeb, :controller

  def index(conn, _params) do
    resp(conn, 200, "ok")
  end
end
