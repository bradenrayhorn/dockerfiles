#!/bin/bash

set -euo pipefail

log() {
    echo "[$(date -u '+%Y-%m-%d %H:%M:%S UTC')] $1"
}

backup_file="$(mktemp -d)/backup.sqlite3"
sqlite3 $DB_PATH ".backup '$backup_file'"

mkdir archive/
cp $backup_file archive/backup.sqlite3

log "Compressing..."
tar -cf - archive | xz -9 > archive.tar.xz

log "Backing up with marmalade"
marmalade backup -f archive.tar.xz
log "Backup process completed successfully!"
