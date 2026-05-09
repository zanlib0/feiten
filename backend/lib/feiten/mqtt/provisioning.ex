defmodule Feiten.Mqtt.Provisioning do
  @moduledoc """
  Reconciles the backend MQTT credential row in `vmq_auth_acl` at boot.

  Idempotent: rerun on every restart so a rotated MQTT_PASSWORD self-heals.
  Run as a transient `Task` child between `Feiten.Repo` and the MQTT
  connection so the Repo is already up and the connection waits until we're
  done.
  """

  alias Feiten.Repo

  require Logger

  def start_link(_opts) do
    Task.start_link(__MODULE__, :ensure_backend_credential!, [])
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      restart: :transient,
      type: :worker
    }
  end

  def ensure_backend_credential! do
    cfg = Application.fetch_env!(:feiten, Feiten.Mqtt)
    username = Keyword.fetch!(cfg, :username)
    password = Keyword.fetch!(cfg, :password)
    client_id = Keyword.fetch!(cfg, :client_id)

    publish_acl = []
    subscribe_acl = [%{"pattern" => "airgradient/#"}]

    Repo.query!(
      """
      INSERT INTO vmq_auth_acl
        (mountpoint, client_id, username, password, publish_acl, subscribe_acl)
      VALUES ($1, $2, $3, crypt($4, gen_salt('bf')), $5, $6)
      ON CONFLICT (mountpoint, client_id, username)
      DO UPDATE SET
        password = crypt($4, gen_salt('bf')),
        publish_acl = EXCLUDED.publish_acl,
        subscribe_acl = EXCLUDED.subscribe_acl
      """,
      [
        "",
        client_id,
        username,
        password,
        publish_acl,
        subscribe_acl
      ]
    )

    Logger.info("MQTT backend credential reconciled for #{username}/#{client_id}")
    :ok
  end
end
