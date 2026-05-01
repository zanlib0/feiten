defmodule FeitenWeb.Router do
  use FeitenWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  if Application.compile_env(:feiten, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: FeitenWeb.Telemetry
    end
  end

  scope "/api", FeitenWeb do
    pipe_through :api

    get "/health", HealthcheckController, :index
  end

end
