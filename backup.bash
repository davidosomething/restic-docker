#!/bin/bash

set -e

source "$(dirname "$0")/util.bash"

__log "[INFO] Starting backup"
[ -n "$RESTIC_BACKUP_ARGS" ] && __log "[INFO] RESTIC_BACKUP_ARGS: ${RESTIC_BACKUP_ARGS}"

start=$(date +%s)
# shellcheck disable=SC2086
restic backup /data \
  ${RESTIC_BACKUP_ARGS} \
  --tag="${RESTIC_TAG}"
rc=$?
end="$(date +%s)"
elapsed="$(__humantime "$((end-start))")"

if [[ $rc == 0 ]]; then
  __log "[INFO] Backup succeeded after ${elapsed}"
  __notify "backup complete" "succeeded after ${elapsed}"
  __webhook_notify "true" "" "${elapsed}"
else
  __log "[ERROR] Backup failed after ${elapsed}"
  __notify "backup failed" "failed after ${elapsed}"
  __webhook_notify "false" "backup failed" "${elapsed}"
  # Only unlock if the repository appears to be locked
  if restic list locks &>/dev/null && [ "$(restic list locks 2>/dev/null | wc -l)" -gt 0 ]; then
    __log "[INFO] Attempting to unlock repository"
    restic unlock
  fi
  exit 1
fi
