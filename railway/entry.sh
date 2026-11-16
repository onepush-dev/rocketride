#!/bin/sh
# Railway entrypoint for the RocketRide engine (upstream engine unmodified).
# Railway volumes are mounted root-owned, but the engine runs as uid 1000 and refuses to start when
# /opt/data is not writable. Fix ownership once as root, then drop to uid 1000 and start the engine
# on 0.0.0.0:${ROCKETRIDE_PORT}.
set -e
mkdir -p /opt/data
chown -R 1000:1000 /opt/data 2>/dev/null || true
if [ -z "${ROCKETRIDE_APIKEY:-}" ]; then
  echo "railway: WARNING ROCKETRIDE_APIKEY is empty, so anyone who finds this URL can run pipelines" >&2
else
  echo "railway: engine API key auth is ON (ROCKETRIDE_APIKEY)"
fi
cd /opt/rocketride
exec setpriv --reuid=1000 --regid=1000 --init-groups ./engine ./ai/eaas.py --host=0.0.0.0 --port="${ROCKETRIDE_PORT:-8080}" "$@"
