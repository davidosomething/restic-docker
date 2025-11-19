#!/bin/bash

set -e

source "$(dirname "$0")/util.bash"

__log "[INFO] Starting prune"

start=$(date +%s)
restic prune
rc=$?
end=$(date +%s)
elapsed="$(__humantime "$((end-start))")"

if [[ $rc == 0 ]]; then
  __log "[INFO] Prune succeeded after ${elapsed}"
  __notify "prune complete" "succeeded after ${elapsed}"
else
  __log "[ERROR] Prune failed after ${elapsed}"
  __notify "prune failed" "failed after ${elapsed}"
  # Only unlock if the repository appears to be locked
  if restic list locks &>/dev/null && [ "$(restic list locks 2>/dev/null | wc -l)" -gt 0 ]; then
    __log "[INFO] Attempting to unlock repository"
    restic unlock
  fi
  exit 1
fi
