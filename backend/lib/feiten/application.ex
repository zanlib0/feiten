defmodule Feiten.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FeitenWeb.Telemetry,
      Feiten.Repo,
      {DNSCluster, query: Application.get_env(:feiten, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Feiten.PubSub},
      FeitenWeb.Endpoint
    ]

    children = children ++ mqtt_children()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Feiten.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FeitenWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp mqtt_children do
    if Application.get_env(:feiten, :start_mqtt?, true) do
      [
        Feiten.Mqtt.Provisioning,
        Feiten.Mqtt.Connection
      ]
    else
      []
    end
  end
end
