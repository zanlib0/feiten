# Claude Project Guidelines

Feiten is an application for gathering data from AirGradient One indoor air monitors.

## Domain glossary
- Sensor: an entity representing a physical sensor, consisting of a name, serial number and an optional description
- Reading: a single instance of fetching data from a sensor. Contains various information about the environment in which the sensor is.

## Stack
The application consists of an Elixir backend in `backend/` and a React+Vite frontend in `frontend/`.

## Approach
- Make the smallest, most direct change that addresses the request. Do not expand scope (e.g., switching environments, modifying test config, adding reverse proxies) without asking.
- Do not launch Agent/Task tools for codebase exploration unless explicitly asked. Prefer direct Read/Grep on the specific file the user named.
- When debugging, propose ONE hypothesis at a time and confirm before pivoting. Avoid stacking speculative fixes (MTU, SHA pins, etc.).
