# ShipIt

The sample application for the **DevOps: CI/CD** course. ShipIt is a small
ASP.NET Core (.NET 10) service with a visible status page, health endpoints, and
an in-memory shipment API. You take this one app from a single commit all the way
to a monitored production deployment across the two days.

This repository is the **starter**. It contains only the app and its tests. You
add everything else during the labs:

| You build it in | What you add |
|---|---|
| Module 2 / Lab 2 | `.github/workflows/ci.yml` (build + test) |
| Module 3 / Lab 3 | `Dockerfile` and the push to Azure Container Registry |
| Module 4 / Lab 4 | Dependabot, CodeQL, secret scanning, and the PR gate |
| Module 5 / Lab 5 | `.github/workflows/cd.yml` (gated promotion + rollback) |
| Module 6 / Lab 6 | `charts/shipit/` (the Helm chart) |
| Module 7 / Lab 7 | `infra/main.bicep` and Application Insights instrumentation |

## Run it locally

```bash
dotnet run --project src/ShipIt
# then open http://localhost:8080
```

- `GET /` — status page (app version, region, banner color, ready state)
- `GET /healthz` — liveness (always 200 while the process is up)
- `GET /readyz` — readiness (200, or 503 when `SHIPIT_READY=false`)
- `GET /api/shipments`, `GET /api/shipments/{id}`, `POST /api/shipments`

## Build and test

```bash
dotnet build
dotnet test
```

## Configuration (environment variables)

These are read at runtime, never baked into the image. On Kubernetes they come
from a ConfigMap (Module 6); locally they fall back to defaults.

| Variable | Default | Purpose |
|---|---|---|
| `SHIPIT_REGION` | `local` | Shown on the status page and banner |
| `SHIPIT_BANNER_COLOR` | `green` | Status-page banner color (change per environment) |
| `SHIPIT_VERSION` | `0.1.0-dev` | Version label on the status page (the pipeline sets this) |
| `SHIPIT_READY` | `true` | Set to `false` to force `/readyz` to 503 and simulate a bad deploy (Labs 5, 7) |
| `ASPNETCORE_URLS` | `http://0.0.0.0:8080` | Listen address; defaults to port 8080 to match the container and the probes |

## Layout

```
src/ShipIt/           the app (minimal API + status page + in-memory store)
tests/ShipIt.Tests/   xUnit integration tests (WebApplicationFactory)
scripts/              check-prereqs.sh (Lab 0 toolchain check)
global.json           pins the .NET 10 SDK
```

## Prerequisites

.NET 10 SDK, and for the later labs: Docker, kubectl, Helm, and the Azure CLI.
Run `./scripts/check-prereqs.sh` (Lab 0) to confirm your toolchain.
