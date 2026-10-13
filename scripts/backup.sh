#!/usr/bin/env bash
set -euo pipefail
source /root/.restic-env

HC="https://hc-ping.com/3e94d9c6-2e76-42f6-ad2c-b10522d2810d"
SNAP=srv-backup
MNT=/mnt/srv-snap

cleanup() {
  umount "$MNT" 2>/dev/null || true
  lvremove -y "ubuntu-vg/$SNAP" >/dev/null 2>&1 || true
}
trap cleanup EXIT

curl -fsS -m 10 --retry 3 "$HC/start" > /dev/null || true

lvcreate -s -L 30G -n "$SNAP" ubuntu-vg/srv
mkdir -p "$MNT"
mount -o ro "/dev/ubuntu-vg/$SNAP" "$MNT"

restic backup "$MNT" --tag nightly --exclude-caches
restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune

curl -fsS -m 10 --retry 3 "$HC" > /dev/null
