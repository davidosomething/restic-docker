# Don't need to use golang image since no more compiling
FROM alpine:3.16
# Every hour by default
ENV BACKUP_CRON="0 1 * * *"
ENV RESTIC_TAG=latest
# We're just using pre-built restic now
RUN apk add --update --no-cache bash ca-certificates curl restic tzdata
WORKDIR /root
COPY util.bash entrypoint.bash backup.bash prune.bash forget.bash ./
ENV PATH="./:${PATH}"
RUN chmod a+x ./*.bash
RUN mkdir -p /var/spool/cron/crontabs /data
ENV TZ=America/New_York
ENTRYPOINT ["entrypoint.bash"]
