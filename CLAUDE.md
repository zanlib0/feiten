# Claude Project Guidelines

Feiten is an application for gathering data from AirGradient One indoor air monitors.

## Domain glossary
- Sensor: an entity representing a physical sensor, consisting of a name, serial number and an optional description
- Reading: a single instance of fetching data from a sensor. Contains various information about the environment in which the sensor is.

## Stack
The application consists of an Elixir backend in `backend/` and a React+Vite frontend in `frontend/`.
