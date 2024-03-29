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
  if [ -n "$GOTIFY" ]; then
    curl "$GOTIFY" \
      --form "title=${1}" \
      --form "message=[$(date +"%Y-%m-%d-%H-%M-%S")] ${2}"
  else
    __log "GOTIFY not configured, skipping notify"
  fi
}
