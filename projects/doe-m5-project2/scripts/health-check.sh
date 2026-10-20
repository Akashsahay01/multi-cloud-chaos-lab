#!/usr/bin/env bash
set -Eeuo pipefail
[[ $# -eq 1 ]] || { echo "Usage: $0 <health-url>" >&2; exit 2; }
url="$1"
for attempt in $(seq 1 20); do
  if body="$(curl --fail --silent --show-error --max-time 3 "$url" 2>/dev/null)" && grep -q '"status"[[:space:]]*:[[:space:]]*"ok"' <<<"$body"; then
    echo "Health check passed: $url"
    echo "$body"
    exit 0
  fi
  echo "Health check attempt $attempt/20 failed; retrying" >&2
  sleep 6
done
echo "Health check failed: $url" >&2
exit 1
