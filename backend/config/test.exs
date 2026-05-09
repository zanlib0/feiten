import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :feiten, Feiten.Repo,
  username: "postgres",
  password: "postgres",
  hostname: System.get_env("POSTGRES_HOST", "localhost"),
  database: "feiten_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :feiten, FeitenWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "3fUviwLvs88uRtjMEJr+tRf/24Kxv6zjDtPDqMN3BxA/lAu7V8Xj2q9kPDadmzmu",
  server: false

config :feiten, :start_mqtt?, false

config :feiten, Feiten.Mqtt,
  host: "localhost",
  port: 1883,
  username: "feiten_backend",
  password: "test",
  client_id: "feiten-backend-test",
  public_host: "localhost",
  public_port: 1883

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Sort query params output of verified routes for robust url comparisons
config :phoenix,
  sort_verified_routes_query_params: true
