# Docker Volume Backup

Automated backup solution for Docker volumes and bind mounts using [offen/docker-volume-backup](https://offen.github.io/docker-volume-backup/).

Backs up volumes/mounts on a schedule, encrypts with GPG, stores locally, and auto-prunes old backups.

## Architecture

- **Multi-schedule**: Each service has its own config file in `backup-volume-docker/`
- **Encrypted**: All backups encrypted with GPG passphrase
- **Auto-pruning**: Old backups deleted based on retention policy
- **Local storage**: Archives stored at `${LOCAL_BACKUPS_PATH}/docker-volume-backup`

## Adding a Backup

### 1. Mount Source in docker-compose.yml

Add volume mount to `docker-volume-backup` service:

**For Docker volume:**
```yaml
volumes:
  - my_volume:/backup/my-service-data:ro
```

**For bind mount:**
```yaml
volumes:
  - /srv/docker/myapp/config:/backup/myapp-config:ro
```

### 2. Create Config File

Create `backup-volume-docker/{stack}-{service}-{type}.env`:

```bash
# Source path (matches mount in docker-compose.yml)
BACKUP_SOURCES=/backup/myapp-config

# Output filename (use consistent naming)
BACKUP_FILENAME='daily-{stack}-{service}-{type}-backup-%Y-%m-%dT%H-%M-%S.archive'

# Pruning prefix (must match non-date part of filename)
BACKUP_PRUNING_PREFIX='daily-{stack}-{service}-{type}-backup-'

# Retention (days)
BACKUP_RETENTION_DAYS='7'

# Schedule (cron expression)
BACKUP_CRON_EXPRESSION='0 3 * * *'

# (Optional) Stop container during backup
# BACKUP_STOP_DURING_BACKUP_LABEL=myapp-service

# (Optional) For pre/post scripts
# EXEC_LABEL=myapp
```

**Key variables:**
- `BACKUP_SOURCES` - Container path to backup (from volume mount)
- `BACKUP_FILENAME` - Output archive name (supports strftime)
- `BACKUP_PRUNING_PREFIX` - Pattern for identifying old backups
- `BACKUP_RETENTION_DAYS` - Keep backups for N days
- `BACKUP_CRON_EXPRESSION` - When to run (default: `@daily`)

**Naming convention:**
```
daily-{stack}-{service}-{type}-backup-YYYY-MM-DDTHH-MM-SS.archive
```

Examples:
- `daily-auth-authentik-postgresql-dump-backup-2026-02-24T03-00-00.archive`
- `daily-streaming-jellyfin-config-backup-2026-02-24T03-00-00.archive`

### 3. (Optional) Stop Container During Backup

Add label to target container in its docker-compose.yml:

```yaml
services:
  myapp:
    labels:
      - docker-volume-backup.stop-during-backup=myapp-service
```

Then reference in backup config:
```bash
BACKUP_STOP_DURING_BACKUP_LABEL=myapp-service
```

**Stop without restart:**
```yaml
labels:
  - docker-volume-backup.stop-during-backup-no-restart=myapp-service
```

### 4. (Optional) Pre/Post Scripts (Database Dumps)

**In target container's docker-compose.yml:**
```yaml
services:
  postgres:
    volumes:
      - db_dumps:/tmp/dumps
    labels:
      - docker-volume-backup.archive-pre=/bin/sh -c 'pg_dump -U user db > /tmp/dumps/dump.sql'
      - docker-volume-backup.exec-label=postgres-db
```

**In backup config:**
```bash
EXEC_LABEL=postgres-db
```

**Lifecycle hooks:**
- `docker-volume-backup.archive-pre` - Before creating tar
- `docker-volume-backup.archive-post` - After creating tar
- `docker-volume-backup.process-pre` - Before encryption
- `docker-volume-backup.process-post` - After encryption
- `docker-volume-backup.copy-pre` - Before upload
- `docker-volume-backup.copy-post` - After upload
- `docker-volume-backup.prune-pre` - Before pruning old backups
- `docker-volume-backup.prune-post` - After pruning

**Custom user for commands:**
```yaml
labels:
  - docker-volume-backup.archive-pre.user=git
  - docker-volume-backup.archive-pre=/bin/bash -c 'gitea dump'
```

**Example: PostgreSQL dump (see `scripts/postgres-backup.sh`):**
```yaml
services:
  authentik-postgresql:
    volumes:
      - authentik_postgresql_dumps:/tmp/dumps
      - ./scripts/postgres-backup.sh:/scripts/postgres-backup.sh:ro
    labels:
      - docker-volume-backup.archive-pre=/bin/sh /scripts/postgres-backup.sh
      - docker-volume-backup.exec-label=authentik-postgresql
      - docker-volume-backup.stop-during-backup=authentik-postgresql-service
```

## Configuration Reference

### Essential Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `BACKUP_SOURCES` | Container path to backup | `/backup/myapp-data` |
| `BACKUP_FILENAME` | Archive filename template | `backup-%Y-%m-%dT%H-%M-%S.archive` |
| `BACKUP_CRON_EXPRESSION` | Backup schedule | `0 3 * * *` (3am daily) |
| `BACKUP_RETENTION_DAYS` | Days to keep backups | `7` |
| `BACKUP_PRUNING_PREFIX` | Pattern for old backup cleanup | `backup-` |

### Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `BACKUP_COMPRESSION` | Compression: `gz`, `zst`, `none` | `gz` |
| `BACKUP_EXCLUDE_REGEXP` | Exclude files matching regex | - |
| `BACKUP_LATEST_SYMLINK` | Symlink to latest backup | - |
| `BACKUP_STOP_DURING_BACKUP_LABEL` | Label value for stopping containers | `true` |
| `EXEC_LABEL` | Filter containers for pre/post commands | - |
| `EXEC_FORWARD_OUTPUT` | Show command output | `false` |

### Global Variables (in docker-compose.yml)

| Variable | Description | Example |
|----------|-------------|---------|
| `GPG_PASSPHRASE` | Encryption passphrase | Set in `.env` |
| `DOCKER_HOST` | Docker socket (via proxy) | `tcp://socket-proxy:2375` |
| `NOTIFICATION_URLS` | Alert destinations (shoutrrr) | `smtp://...` |
| `NOTIFICATION_LEVEL` | Alert level: `error`, `info` | `info` |

## Encryption

All backups are encrypted using GPG symmetric encryption.

**Set passphrase in `.env`:**
```bash
GPG_PASSPHRASE=your-secure-passphrase
```

**Decrypt a backup:**
```bash
gpg --decrypt backup-2026-02-24T03-00-00.archive.gpg | tar -xzf -
```

## Restore

### Method 1: Partial Restore (Specific Files)

Extract backup and copy files to running volume:

```bash
# 1. Extract backup locally
tar -C /tmp -xvf backup-2026-02-24T03-00-00.archive

# 2. Create temp container with volume mounted
docker run -d --name temp_restore -v myapp_data:/restore alpine sleep 3600

# 3. Copy files into volume (adjust path depth as needed)
docker cp /tmp/backup/myapp-data/. temp_restore:/restore/

# 4. Cleanup
docker stop temp_restore
docker rm temp_restore
```

### Method 2: Full Volume Rollback

Replace entire volume with backup snapshot:

```bash
# 1. (Optional) Trigger fresh backup first
docker exec docker-volume-backup backup

# 2. Stop containers using the volume
docker stop myapp

# 3. Find exact volume name
docker volume ls | grep myapp

# 4. Remove existing volume
docker volume rm myapp_data

# 5. Restore from archive
docker run --rm -it \
  -v myapp_data:/restore \
  -v ${LOCAL_BACKUPS_PATH}/docker-volume-backup:/archive:ro \
  alpine tar -xvf /archive/daily-stack-myapp-data-backup-2026-02-24T03-00-00.archive -C /restore --strip-components=2

# 6. Restart containers
docker start myapp
```

**Note:** Adjust `--strip-components=N` based on archive structure. Check with:
```bash
tar -tvf backup.archive | head
```

## Manual Trigger

Run backup immediately:

```bash
docker exec docker-volume-backup backup
```

Run specific schedule:
```bash
docker exec docker-volume-backup backup -c /etc/dockervolumebackup/conf.d/my-service.env
```

## Troubleshooting

**View loaded configuration:**
```bash
docker exec docker-volume-backup cat /etc/dockervolumebackup/conf.d/my-service.env
```

**Check logs:**
```bash
docker logs docker-volume-backup
docker logs -f docker-volume-backup  # follow
```

**Test cron expression:**
Use [crontab.guru](https://crontab.guru/) or:
```bash
# Daily at 3am
0 3 * * *

# Every 6 hours
0 */6 * * *

# Weekly on Sunday at 2am
0 2 * * 0
```

**Verify backup files:**
```bash
ls -lh ${LOCAL_BACKUPS_PATH}/docker-volume-backup/
```

**Check encryption:**
```bash
# Should show "GPG encrypted data"
file backup.archive.gpg

# Test decrypt
gpg --decrypt backup.archive.gpg > /tmp/test.tar.gz
```

## Documentation

Full documentation: https://offen.github.io/docker-volume-backup/
