#!/usr/bin/env bash
set -Eeuo pipefail

if [ ! -d /data ]; then
  echo "ERROR: You did not bind the /data folder!" && exit 18
fi

# Create directories
mkdir -p "/images"

trap "pkill -SIGINT -f umbreld; while pgrep umbreld >/dev/null; do sleep 1; done" SIGINT SIGTERM

umbreld --data-directory /data
