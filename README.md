# Feiten

Air quality monitoring — project notes.

Indoor air quality monitoring, starting as a self-hosted home dashboard for a single AirGradient sensor. The eventual aspiration is to grow this into a small SaaS product targeting schools and offices in Silesia, Poland — but everything below is scoped to the technical bootstrap, not the business.

## Stages

### Stage 1 — Home dashboard (single sensor, self-hosted)

Goal: a deployable Docker stack I can host on my own infra (Gitea + Portainer) that ingests readings from one AirGradient sensor and shows them live on a dashboard.

Scope:

- Phoenix (Channels) + React for the dashboard
- TimescaleDB for readings
- One sensor, polled directly over HTTP from its local API (pull model for Stage 1)
- No MQTT, no auth, no notifications, no multi-tenancy

Out of scope at this stage: anything that isn't required to get one sensor's data on a screen in my house.

### Stage 2 — MQTT (and flip to push)

Replace the Stage 1 HTTP polling with MQTT so the ingestion path matches what a multi-sensor / multi-site deployment will need later. This is also where the model flips from pull to push: sensors publish to the broker instead of us reaching into their LAN.

- VerneMQ broker (Erlang-based, BEAM-native, single Docker container; Apache 2.0)
- Tortoise311 as the MQTT subscriber in the supervision tree
- Topic shape: `airquality/{location_id}/{sensor_serial}/readings` and `.../status`
- QoS 1 for readings, dedupe on `(sensor_id, time)` at insert
- LWT on the status topic for free offline detection

### Stage 3 — Auth

Add user accounts and per-sensor credentials so the system is safe to expose beyond my LAN.

- Phoenix auth for dashboard users
- Per-device MQTT credentials (random password per sensor, hashed in DB)
- VerneMQ's bundled `vmq_diversity` plugin pointed at Postgres for device auth + ACLs, so each device can only publish under its own namespace (no broker swap from Stage 2 — same VerneMQ container, just flip anonymous off and enable the Postgres auth hooks)

## Architecture notes

### Why TimescaleDB

PostgreSQL extension; existing Ecto/Postgrex tooling works unchanged. The `timescale` Hex package by davydog187 provides Ecto macros for hypertable migrations and hyperfunctions (`time_bucket`, `time_bucket_gapfill`, `interpolate`, `first`/`last`, `histogram`).

Key features for this workload:

- **Hypertables** — automatic time-based partitioning
- **Continuous aggregates** — incrementally materialized rollups (1-min averages, hourly maxes) so dashboards query pre-computed views instead of scanning raw rows
- **Compression** — columnar with delta-of-delta + Gorilla, typically 10-20× on sensor data
- **Gapfill + interpolate** — clean charts even when readings are missing

### Schema shape

Wide rows with typed columns (one row per reading, columns for `pm25`, `co2`, `temp`, etc.) — NOT JSONB blobs and NOT EAV. Time-series compression and queries both prefer wide rows.

### Storage estimate (forward-looking, 20 sensors)

For 20 sensors × 1 reading / 5s × 24 numeric metrics:

- ~126M rows/year
- **Uncompressed:** ~35-40 GB (data + indexes)
- **Compressed (chunks > 7 days):** ~3-4 GB

Single sensor at Stage 1 is negligible.

### Push, not pull (Stage 2 onward)

Sensors readings to our infrastructure rather than us polling them. Implications:

- No persistent network access into the sensor's LAN required after install
- Customer firewalls just see normal outbound TCP — no VPN, port forwarding, or relay agent
- WiFi setup is one-time at install via the device's captive portal
- No on-site equipment beyond the sensors themselves

VerneMQ exposes MQTTS on 8883; can fall back to MQTT-over-WebSockets on 443 if a firewall blocks 8883.

## Tech stack

| Layer | Choice | Stage |
|-------|--------|-------|
| Sensor | AirGradient ONE (I-9PSL), stock firmware | 1 |
| Application | Phoenix + React (Channels for live updates) | 1 |
| Time-series DB | TimescaleDB (extension on Postgres) | 1 |
| App DB | Same Postgres instance | 1 |
| Reverse proxy / TLS | Caddy | 1 |
| Deployment | Docker stack on self-hosted infra (Gitea + Portainer) | 1 |
| Transport | MQTT over TLS (8883), fallback WSS (443) | 2 |
| Broker | VerneMQ (Apache 2.0, BEAM-native) | 2 |
| MQTT client | Tortoise311 | 2 |
| Auth | Phoenix auth + VerneMQ `vmq_diversity` Postgres-backed device auth/ACL | 3 |

## Deployment

### Current (LAN-only)

Production runs as a single Docker host on the home LAN. AdGuard rewrites internal hostnames (e.g. `verne.feiten.jerusalem.ovh`) to the host's LAN IP; sensors connect plaintext to vernemq on `MQTT_INTERNAL_PORT`. NPM handles HTTPS for the dashboard frontend only — MQTT does not pass through it.

Accepted trade-off: MQTT credentials traverse the LAN in plaintext. Fine on a trusted network, not fine for internet-facing sensors.

### TODO — Going public (TLS / mqtts)

Required once sensors live outside the LAN (likely a future Hetzner deploy). Two viable shapes; pick one when the time comes:

1. **Traefik in compose (preferred).** Add a `traefik` service to `docker-compose.prod.yml`, give vernemq labels for a TCP router on an `mqtts` entrypoint, drop vernemq's host port binding. Let's Encrypt via DNS-01 (Cloudflare API token). Cert renewal is fully automatic — no restart needed. Then flip `MQTT_PUBLIC_SCHEME=mqtts` and point `MQTT_PUBLIC_PORT` at the Traefik entrypoint.
2. **VerneMQ terminates TLS itself.** Set `DOCKER_VERNEMQ_LISTENER__SSL__*`, mount a cert dir from the host, expose vernemq's TLS port. Cert renewal requires a restart hook (certbot deploy hook or weekly cron).

NPM is **not** a candidate. Its Stream UI is raw TCP passthrough (can't unwrap TLS); Proxy Hosts only speak HTTP. Using NPM only makes sense as a redundant port-forwarding hop in front of one of the two options above.

When making the switch, also restore `127.0.0.1:` on vernemq's `ports:` line so plaintext is reachable only from the host (for local debug), and rely on the chosen terminator for public traffic.
