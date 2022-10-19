#!/bin/bash

set -e

log_date=$(date +"%Y-%m-%d-%H-%M-%S")
log_file="/var/log/restic/prune/${log_date}.log"

log() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")]$1" | tee -a "$log_file"
}

showTime() {
    num=$1
    min=0
    hour=0
    day=0
    if((num>59));then
        ((sec=num%60))
        ((num=num/60))
        if((num>59));then
            ((min=num%60))
            ((num=num/60))
            if((num>23));then
                ((hour=num%24))
                ((day=num/24))
            else
                ((hour=num))
            fi
        else
            ((min=num))
        fi
    else
        ((sec=num))
    fi
    time="${day}d ${hour}h ${min}m ${sec}s"
    log "[INFO] Total prune time: ${time}"
}

start=$(date +%s)
log "[INFO] Starting prune"
log "[INFO] Log filename: ${log_file}"

log "[INFO] Starting prune process"
restic prune | tee -a "$log_file"
rc=$?
if [[ $rc == 0 ]]; then
    log "[INFO] Prune succeeded"
    [ -n "$GOTIFY" ] && curl "$GOTIFY" \
      -F "title=restic prune complete" \
      -F "message=[${log_date}] returned ${rc} on ${end}" \
      -F "priority=5"
else
    log "[ERROR] Prune failed with status $rc"
    restic unlock
    [ -n "$GOTIFY" ] && curl "$GOTIFY" \
      -F "title=restic prune failed" \
      -F "message=[${log_date}] returned ${rc} on ${end}" \
      -F "priority=5"
fi

end=$(date +%s)
log "[INFO] Finished prune at $(date)"
showTime $((end-start))
