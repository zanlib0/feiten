# Feiten

Feiten gathers air quality data from [AirGradient ONE](https://www.airgradient.com/indoor/) indoor air monitors and shows it on a self-hosted dashboard.

Sensors publish their readings over MQTT to a VerneMQ broker. An Elixir/Phoenix backend subscribes to the broker, persists each reading into a TimescaleDB hypertable, and serves a JSON API. A React frontend renders the readings as time-series charts.

Currently deployed in production on a homelab, behind Cloudflare Access. Code hosted on self-hosted Gitea instance, using Gitea CI and Docker container registry. Deployed using Portainer.

## Stack

| Layer | Choice |
|-------|--------|
| Sensor | AirGradient ONE (I-9PSL), stock firmware |
| Backend | Elixir / Phoenix (JSON API) with [Tortoise311](https://hex.pm/packages/tortoise311) as the MQTT client |
| Database | TimescaleDB (PostgreSQL extension) |
| MQTT broker | VerneMQ 2.1.2 with `vmq_diversity` Postgres auth/ACL |
| Frontend | React 19 + Vite + TypeScript, React Query, Recharts, wouter |
| Reverse proxy | Caddy (serves the built frontend, proxies `/api` to the backend) |
| Deployment | Docker Compose |

## Development

### Backend

```sh
docker compose up -d        # Postgres (TimescaleDB) + VerneMQ
cd backend
mix setup                   # install deps, create + migrate DB, run seeds
mix phx.server              # http://localhost:4000
```

The backend reads its database and MQTT settings from environment variables (see `backend/config/dev.exs` for defaults). The MQTT subscriber starts with the application; set `config :feiten, start_mqtt?: false` to disable it.

### Frontend

```sh
cd frontend
npm install
npm run dev
```

## Deployment

`docker-compose.prod.yml` runs the full stack — TimescaleDB, VerneMQ, the backend release, and the Caddy-served frontend — using prebuilt images from the project registry.

Copy `.env.prod.example` to `.env.prod` and fill in the required values.

Optional settings (`PHX_HOST`, `HTTP_PORT`, `MQTT_INTERNAL_PORT`, `MQTT_PUBLIC_SCHEME`, `MQTT_PUBLIC_PORT`, `POOL_SIZE`) have sensible defaults documented in `.env.prod.example`.

```sh
docker compose -f docker-compose.prod.yml --env-file .env.prod up -d
```

VerneMQ exposes a plaintext MQTT listener on `MQTT_INTERNAL_PORT` (default `1883`). This is appropriate for a trusted LAN; MQTT credentials traverse the network in plaintext. For internet-facing deployments, put a TLS terminator in front of the broker.
