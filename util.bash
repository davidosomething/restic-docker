export start

__humantime() {
  num=$1
  min=0
  hour=0
  day=0
  if ((num > 59)); then
    ((sec = num % 60))
    ((num = num / 60))
    if ((num > 59)); then
      ((min = num % 60))
      ((num = num / 60))
      if ((num > 23)); then
        ((hour = num % 24))
        ((day = num / 24))
      else
        ((hour = num))
      fi
    else
      ((min = num))
    fi
  else
    ((sec = num))
  fi
  echo "${day}d ${hour}h ${min}m ${sec}s"
}

__log() {
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] ${1}"
}

__notify() {
  if [ -z "$GOTIFY" ]; then
    __log "GOTIFY not configured, skipping notify"
    return
  fi
  curl "$GOTIFY" \
    --form "title=${1}" \
    --form "message=[$(date +"%Y-%m-%d-%H-%M-%S")] ${2}" ||
    __log "Failed to reach gotify server"
}

__webhook_notify() {
  local success="$1"
  local error="$2"

  if [ -z "$WEBHOOK_SUCCESS" ]; then
    __log "WEBHOOK_SUCCESS not configured, skipping webhook"
    return
  fi

  if [ -z "$WEBHOOK_TOKEN" ]; then
    __log "WEBHOOK_TOKEN not configured, skipping webhook"
    return
  fi

  local url="${WEBHOOK_SUCCESS}?success=${success}&error=${error}"
  printf "%s\n" "$url"

  if curl -X POST "$url" \
    -H "Authorization: Bearer ${WEBHOOK_TOKEN}" \
    --fail \
    --silent \
    --show-error; then
    __log "[INFO] Webhook notification sent successfully"
  else
    __log "[ERROR] Failed to send webhook notification"
  fi
}
