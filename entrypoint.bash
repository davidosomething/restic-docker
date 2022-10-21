#!/bin/bash

set -e

source ./util.bash

repoInitialized() {
  restic snapshots || {
    __log "[INFO] Repository is not initialized"
    return 1
  }
}

initializeRepo() {
  restic init || {
    __log "[ERROR] Failed to initialize repo"
    return 1
  }
  __log "[INFO] Repo initialized"
}

checkRepoStatus() {
  __log "[INFO] Checking restic repository status ..."
  repoInitialized || initializeRepo
}

restic version

__log "[INFO] Starting container ..."
__log "[INFO] Backup cron schedule is set to: ${BACKUP_CRON}"
echo "${BACKUP_CRON} /root/backup.bash >> $LOG 2>&1" > /var/spool/cron/crontabs/root

if [ -n "${FORGET_CRON}" ]; then
  echo "${FORGET_CRON} /root/forget.bash >> $LOG 2>&1" >> /var/spool/cron/crontabs/root
  __log "[INFO] Forget cron schedule is set to: ${FORGET_CRON}"
fi

if [ -n "${PRUNE_CRON}" ]; then
  echo "${PRUNE_CRON} /root/prune.bash >> $LOG 2>&1" >> /var/spool/cron/crontabs/root
  __log "[INFO] Prune cron schedule is set to: ${PRUNE_CRON}"
fi

__log "[INFO] Timezone is set to: ${TZ}"
__log "[INFO] Starting cron service"
crond && __log "[INFO] Cron service started successfully"

# If the repo has never been initialized, init the repo
checkRepoStatus

__log "[INFO] Container started"
__notify "container started" "$(restic version)"
tail -fn0 "$LOG"
