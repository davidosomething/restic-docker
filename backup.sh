#!/bin/bash

set -e
# credit: some of the code for this script inspired by
# https://github.com/lobaro/restic-backup-docker

log_date=$(date +"%Y-%m-%d-%H-%M-%S")
log_file="/var/log/restic/backup/${log_date}.log"

log() {
  echo "[$(date +"%Y-%m-%d %H:%M:%S")]$1" | tee -a "$log_file"
}

showTime() {
  num=$1
  min=0
  hour=0
  day=0
  if ((num>59)); then
    ((sec=num%60))
    ((num=num/60))
    if ((num>59)); then
      ((min=num%60))
      ((num=num/60))
      if ((num>23)); then
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
  log "[INFO] Total backup time: ${time}"
}

start=$(date +%s)
log "[INFO] Starting backup"
log "[INFO] Log filename: ${log_file}"

if [ -n "$RESTIC_BACKUP_ARGS" ]; then
  log "[INFO] RESTIC_BACKUP_ARGS: ${RESTIC_BACKUP_ARGS}"
fi

restic backup /data "${RESTIC_BACKUP_ARGS}" --tag="${RESTIC_TAG}" |
  tee -a "$log_file"
rc=$?

end="$(date +%s)"

if [[ $rc == 0 ]]; then
  log "[INFO] Backup succeeded"

  [ -n "$GOTIFY" ] && curl "$GOTIFY" \
    -F "title=restic backup complete" \
    -F "message=[${log_date}] completed on ${end}" \
    -F "priority=5"
else
  log "[ERROR] Backup failed with status ${rc}"
  restic unlock
  copyErrorLog
  kill 1

  [ -n "$GOTIFY" ] && curl "$GOTIFY" \
    -F "title=restic backup failed" \
    -F "message=[${log_date}] returned ${rc} on ${end}" \
    -F "priority=5"
fi

log "[INFO] Finished backup at $(date)"
showTime "$((end-start))"
