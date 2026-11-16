# RocketRide on Railway

[RocketRide](https://github.com/rocketride-org/rocketride-server) (MIT) is an open-source AI pipeline engine. You build pipelines from 50+ nodes: LLMs, embeddings, OCR, parsers, chunkers, vector stores and agents. You run them from the browser UI, the VS Code extension, the Python/TypeScript SDKs or MCP clients. This template deploys the engine on Railway with one click, with a pgvector database alongside.

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/TEMPLATE_CODE)

## What this template runs

- **rocketride**: `ghcr.io/onepush-dev/rocketride-engine:3.6.0`. This is the official `ghcr.io/rocketride-org/rocketride-engine:3.6.0` image, with the engine itself unmodified, plus a small entrypoint. The entrypoint fixes ownership of the Railway volume and then drops to the upstream non-root user (uid 1000). The service has a public HTTPS domain on port 8080, a healthcheck on `/version` and a volume at `/opt/data` for engine data and per-node Python packages.
- **pgvector**: `pgvector/pgvector:0.8.0-pg16`, the vector store that the upstream compose stack treats as required. It uses a private network only and a volume at `/var/lib/postgresql/data`.

## Variables

| Service | Variable | Value | Notes |
|---|---|---|---|
| rocketride | `ROCKETRIDE_APIKEY` | generated secret | Every client (UI, SDK, VS Code, MCP) must present this key. Without it, the engine is open to anyone. |
| rocketride | `POSTGRES_URL` | `${{pgvector.DATABASE_URL}}` | Connection string for the pgvector store. Use it in pgvector nodes. |
| pgvector | `POSTGRES_PASSWORD` | generated secret | Database superuser password. |
| pgvector | `PGDATA` | `${{RAILWAY_VOLUME_MOUNT_PATH}}/pgdata` | Data directory on the volume. |
| pgvector | `DATABASE_URL` | `postgresql://postgres:…@pgvector.railway.internal:5432/postgres` | Private connection string. |

Baked into the image: `ROCKETRIDE_PORT=8080`, `ROCKETRIDE_LOG_LEVEL=info`.

## How to use

1. Deploy, then copy `ROCKETRIDE_APIKEY` from rocketride → Variables.
2. Open the public domain and enter the key when the UI asks for it. Alternatively, point the **RocketRide VS Code extension** or an SDK at `https://<your-domain>` with that key:
   ```python
   from rocketride import RocketRideClient
   client = RocketRideClient(uri="https://<your-domain>", auth="<ROCKETRIDE_APIKEY>")
   ```
3. Add your model provider keys (OpenAI, Anthropic, Gemini, Ollama…) in the pipeline nodes that need them. The engine itself needs none of them to start.
4. In pgvector store nodes, use host `pgvector.railway.internal`, port `5432`, user `postgres`, database `postgres` and the pgvector service's `POSTGRES_PASSWORD`.

## Notes

- Milvus (with etcd and MinIO) and ChromaDB are **optional** stores in the upstream dev compose file, and the engine does not wait for them. Add them as extra Railway services if your pipelines use those nodes.
- Endpoints: `/version` is public. `/ping`, `/task` and the `/task/service` WebSocket require the API key.
- The first run of a node installs that node's Python packages, so the first pipeline run can take a minute.
- Not affiliated with RocketRide or Aparavi.
