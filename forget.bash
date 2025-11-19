#!/bin/bash

set -e

source "$(dirname "$0")/util.bash"

__log "[INFO] Starting forget"
__log "[INFO] RESTIC_FORGET_ARGS: ${RESTIC_FORGET_ARGS}"

if [ -n "${RESTIC_FORGET_ARGS}" ]; then
  start=$(date +%s)
  restic forget "${RESTIC_FORGET_ARGS}"
  rc=$?
  end=$(date +%s)
  elapsed="$(__humantime "$((end-start))")"

  if [[ $rc == 0 ]]; then
    __log "[INFO] Forget succeeded after ${elapsed}"
    __notify "forget complete" "succeeded after ${elapsed}"
  else
    __log "[ERROR] Forget failed after ${elapsed}"
    __notify "forget failed" "failed after ${elapsed}"
    # Only unlock if the repository appears to be locked
    if restic list locks &>/dev/null && [ "$(restic list locks 2>/dev/null | wc -l)" -gt 0 ]; then
      __log "[INFO] Attempting to unlock repository"
      restic unlock
    fi
  fi
fi
