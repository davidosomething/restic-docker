#!/bin/bash

set -e

source ./util.bash

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
  restic unlock
  kill 1
fi
