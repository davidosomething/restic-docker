FROM alpine:3.21

LABEL org.opencontainers.image.title="restic-docker" \
      org.opencontainers.image.description="Automated restic backup container with scheduled backups, pruning, and forget operations" \
      org.opencontainers.image.source="https://github.com/davidosomething/restic-docker"

# Every hour by default
ENV TZ=America/New_York
ENV BACKUP_CRON="0 1 * * *"
ENV RESTIC_TAG=latest
ENV WEBHOOK_TOKEN=""
ENV WEBHOOK_SUCCESS=""

# We're just using pre-built restic now
RUN apk add --no-cache bash ca-certificates curl restic tzdata

WORKDIR /root
COPY --chmod=0755 util.bash entrypoint.bash backup.bash prune.bash forget.bash ./

RUN mkdir -p /var/log /var/spool/cron/crontabs /data && \
    touch /var/log/cron.log

HEALTHCHECK --interval=1h --timeout=10s --start-period=30s --retries=3 \
    CMD restic snapshots --last || exit 1

ENTRYPOINT ["/bin/bash", "/root/entrypoint.bash"]
CMD ["tail", "-fn0", "/var/log/cron.log"]
