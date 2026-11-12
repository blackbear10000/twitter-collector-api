#!/usr/bin/env bash
# Minimal authenticated request helper for twitter-collector-api skill.
# Usage:
#   ./scripts/request.sh GET /api/watchlist/groups
#   ./scripts/request.sh POST /api/workflows/1/run '{"reason":"manual via agent"}'
set -euo pipefail

method="${1:-}"
path="${2:-}"
body="${3:-}"

if [[ -z "${method}" || -z "${path}" ]]; then
  echo "usage: $0 METHOD /api/... [json_body]" >&2
  exit 1
fi

if [[ -z "${TWITTER_COLLECTOR_URL:-}" ]]; then
  echo "TWITTER_COLLECTOR_URL is not set" >&2
  exit 1
fi
if [[ -z "${TWITTER_COLLECTOR_API_KEY:-}" ]]; then
  echo "TWITTER_COLLECTOR_API_KEY is not set" >&2
  exit 1
fi

base="${TWITTER_COLLECTOR_URL%/}"
if [[ "${path}" != /* ]]; then
  path="/${path}"
fi

url="${base}${path}"
args=(-sS -X "${method}" -H "X-API-Key: ${TWITTER_COLLECTOR_API_KEY}" -H "Accept: application/json")

if [[ -n "${body}" ]]; then
  args+=(-H "Content-Type: application/json" -d "${body}")
fi

curl "${args[@]}" "${url}"
echo
