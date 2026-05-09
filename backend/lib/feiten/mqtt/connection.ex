defmodule Feiten.Mqtt.Connection do
  @moduledoc """
  Supervised wrapper around `Tortoise311.Connection` that subscribes to the
  AirGradient readings topic and dispatches messages to `Feiten.Mqtt.Handler`.
  """

  def child_spec(_opts) do
    cfg = Application.fetch_env!(:feiten, Feiten.Mqtt)

    host = Keyword.fetch!(cfg, :host)
    port = Keyword.fetch!(cfg, :port)
    username = Keyword.fetch!(cfg, :username)
    password = Keyword.fetch!(cfg, :password)
    client_id = Keyword.fetch!(cfg, :client_id)

    Tortoise311.Connection.child_spec(
      client_id: client_id,
      user_name: username,
      password: password,
      server: {Tortoise311.Transport.Tcp, host: host, port: port},
      handler: {Feiten.Mqtt.Handler, []},
      subscriptions: [{"airgradient/readings/+", 1}]
    )
  end
end
