#!/bin/sh
# Railway wrapper for PatchMon: derive settings Railway already knows, keep
# state on the volume, refuse to start without secrets, then run upstream's
# entrypoint as the non-root user.
set -e

log() { echo "[railway-start] $*" >&2; }

# Railway's Redis exposes REDISHOST/REDISPORT/REDISPASSWORD; PatchMon reads REDIS_*.
export REDIS_HOST="${REDIS_HOST:-${REDISHOST:-}}"
export REDIS_PORT="${REDIS_PORT:-${REDISPORT:-6379}}"
export REDIS_PASSWORD="${REDIS_PASSWORD:-${REDISPASSWORD:-}}"

# CORS_ORIGIN is also PatchMon's Host allow-list: requests for any other host
# get 403. Keep a deployer-set value (custom domain) first, then add the
# Railway public domain and Railway's health-check host, which probes /health
# with "Host: healthcheck.railway.app".
add_origin() {
  case ",${CORS_ORIGIN:-}," in
    *",$1,"*) ;;
    ",,") CORS_ORIGIN="$1" ;;
    *) CORS_ORIGIN="${CORS_ORIGIN},$1" ;;
  esac
}
case "${CORS_ORIGIN:-}" in
  "*") ;;
  *)
    [ -n "${RAILWAY_PUBLIC_DOMAIN:-}" ] && add_origin "https://${RAILWAY_PUBLIC_DOMAIN}"
    add_origin "http://healthcheck.railway.app"
    ;;
esac
export CORS_ORIGIN

# A stable identity for the agent presence registry in Redis (upstream's
# compose file pins the hostname for the same reason).
export POD_ID="${POD_ID:-patchmon-${RAILWAY_SERVICE_ID:-server}}"

for v in DATABASE_URL JWT_SECRET SESSION_SECRET REDIS_HOST; do
  eval "val=\${$v:-}"
  if [ -z "$val" ]; then
    log "ERROR: $v is not set. Refusing to start."
    exit 1
  fi
done

# Web SSH host-key pins live on the volume so they survive redeploys.
known_dir="$(dirname "$PATCHMON_SSH_KNOWN_HOSTS")"
if [ "$(id -u)" = "0" ]; then
  mkdir -p "$known_dir"
  chown -R 65532:65532 "$known_dir"
  chmod 700 "$known_dir"
  log "starting PatchMon as nonroot (CORS_ORIGIN=${CORS_ORIGIN:-unset}, PORT=${PORT})"
  cd /app
  exec su -p -s /bin/sh nonroot -c 'exec /app/entrypoint.sh'
fi

log "starting PatchMon (CORS_ORIGIN=${CORS_ORIGIN:-unset}, PORT=${PORT})"
cd /app
exec /app/entrypoint.sh
