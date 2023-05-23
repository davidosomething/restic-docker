# restic-docker

This is a fork of @csumpter's [restic-docker](https://github.com/csumpter/restic-docker).
I'll be maintaining this version for my own use.

## Usage

### Environment Variables

- [REQUIRED] `RESTIC_REPOSITORY` - the location of your restic repository. For
  [BackBlaze B2](https://www.backblaze.com/b2/cloud-storage.html) that would
  be `b2:<bucket-name>:/`
- [REQUIRED] `RESTIC_PASSWORD` - repository password
- [OPTIONAL] `BACKUP_CRON` - default value is `0 1 * * *`
- [OPTIONAL] `RESTIC_BACKUP_ARGS` - example: `-o b2.connections=20`
    - See the full list of options in the restic docs.
- [OPTIONAL] `FORGET_CRON` - example: `1 3 * * 0`
- [OPTIONAL] `RESTIC_FORGET_ARGS` - example: `--keep-last 7` or `--keep-last
  7 --prune` if you wish to perform a prune operation at the same time.
- [OPTIONAL] `PRUNE_CRON` - example: `1 3 * * 1`
- [OPTIONAL] `RESTIC_TAG` - default value is `latest`
- [OPTIONAL] `TZ`
  [timezone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones),
  default is `America/New_York`. Set this value if you want your log entries
  to have the relevant time in them.
- [OPTIONAL] `GOTIFY` - URL with token, e.g.
  `http://mygotify/message?token=abc123`. Will POST to this URL with a message
  on successful backups.

#### Backblaze B2 Setup

- [REQUIRED] `B2_ACCOUNT_ID`
- [REQUIRED] `B2_ACCOUNT_KEY`

### Mounting your data

- Mount all folders to the `/data` folder on the container.

## Credit

Based off work in:

- [csumpter/restic-docker](https://github.com/csumpter/restic-docker)
- [lobaro/restic-backup-docker](https://github.com/lobaro/restic-backup-docker)
