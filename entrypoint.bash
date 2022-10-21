#!/bin/bash

set -e

source ./util.bash

__log "[INFO] Starting container ..."
__log "[INFO] Backup cron schedule is set to: ${BACKUP_CRON}"
echo "${BACKUP_CRON} /root/backup.bash" > /var/spool/cron/crontabs/root

if [ -n "${FORGET_CRON}" ]; then
  __log "[INFO] Forget cron schedule is set to: ${FORGET_CRON}"
  echo "${FORGET_CRON} /root/forget.bash" >> /var/spool/cron/crontabs/root
fi

if [ -n "${PRUNE_CRON}" ]; then
  __log "[INFO] Prune cron schedule is set to: ${PRUNE_CRON}"
  echo "${PRUNE_CRON} /root/prune.bash" >> /var/spool/cron/crontabs/root
fi

__log "[INFO] Timezone is set to: ${TZ}"
__log "[INFO] Starting cron service"
crond && __log "[INFO] Cron service started successfully"

__log "[INFO] Checking restic repository status ..."
restic snapshots || {
  __log "[INFO] Repository is not initialized"
  if ! res=$(restic init 2>&1); then
    __log "[ERROR] Failed to initialize repo"
    __notify "failed to init repo" "$res"
    exit 1
  fi
  __log "[INFO] Repo initialized"
}
__log "[INFO] Container started"
__notify "container started" "$(restic version)"
