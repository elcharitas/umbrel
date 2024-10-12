#!/usr/bin/env bash
set -Eeuo pipefail

mount=$(echo "$resp" | jq -r '.[0].Mounts[] | select(.Destination == "/data").Source')

if [ -z "$mount" ] || [[ "$mount" == "null" ]] || [ ! -d /data ]; then
  echo "ERROR: You did not bind the /data folder!" && exit 18
fi

# Create directories
mkdir -p "/images"

# Convert Windows paths to Linux path
if [[ "$mount" == *":\\"* ]]; then
  mount="${mount,,}"
  mount="${mount//\\//}"
  mount="//${mount/:/}"
fi

# Mirror external folder to local filesystem
if [[ "$mount" != "/data" ]]; then
  mkdir -p "$mount"
  rm -rf "$mount"
  ln -s /data "$mount"
fi

trap "pkill -SIGINT -f umbreld; while pgrep umbreld >/dev/null; do sleep 1; done" SIGINT SIGTERM

umbreld --data-directory "$mount" & wait $!
