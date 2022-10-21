#!/bin/bash

set -e
# credit: some of the code for this script inspired by
# https://github.com/lobaro/restic-backup-docker

source ./util.bash

__log "[INFO] Starting backup"

[ -n "$RESTIC_BACKUP_ARGS" ] && __log "[INFO] RESTIC_BACKUP_ARGS: ${RESTIC_BACKUP_ARGS}"

start=$(date +%s)
restic backup /data \
  "${RESTIC_BACKUP_ARGS}" \
  --tag="${RESTIC_TAG}"
rc=$?
end="$(date +%s)"
elapsed="$(__humantime "$((end-start))")"

if [[ $rc == 0 ]]; then
  __log "[INFO] Backup succeeded after ${elapsed}"
  __notify "backup complete" "succeeded after ${elapsed}"
else
  __log "[ERROR] Backup failed after ${elapsed}"
  __notify "backup failed" "failed after ${elapsed}"
  restic unlock
  kill 1
fi
