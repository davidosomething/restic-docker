# Don't need to use golang image since no more compiling
FROM alpine:3.16
ENV LOG=/var/log/restic/restic.log
ENV BACKUP_CRON="0 1 * * *"
ENV RESTIC_TAG=latest
# We're just using pre-built restic now
RUN apk add --update --no-cache bash ca-certificates curl restic tzdata
WORKDIR /root
COPY entrypoint.sh backup.sh prune.sh forget.sh ./
ENV PATH="./:${PATH}"
RUN chmod a+x ./*.sh
RUN mkdir -p /var/spool/cron/crontabs \
             /var/log/restic/backup \
             /var/log/restic/prune \
             /var/log/restic/forget \
             /data
ENV TZ=America/New_York
ENTRYPOINT ["entrypoint.sh"]
