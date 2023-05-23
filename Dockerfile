FROM alpine:3.18

# Every hour by default
ENV TZ=America/New_York
ENV BACKUP_CRON="0 1 * * *"
ENV RESTIC_TAG=latest

# We're just using pre-built restic now
RUN apk add --update --no-cache bash ca-certificates curl restic tzdata

ENV PATH="./:${PATH}"
WORKDIR /root
COPY --chmod=0755 util.bash entrypoint.bash backup.bash prune.bash forget.bash ./

RUN mkdir -p /var/log /var/spool/cron/crontabs /data
RUN touch /var/log/cron.log

ENTRYPOINT ["entrypoint.bash"]
CMD ["tail", "-fn0", "/var/log/cron.log"]
