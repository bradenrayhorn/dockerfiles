#!/bin/bash

set -euo pipefail

log() {
    echo "[$(date -u '+%Y-%m-%d %H:%M:%S UTC')] $1"
}

# create working directories
backup_dir="$(mktemp -d)"
cd $backup_dir

# setup auth
keyfile="$(mktemp -d)/key"
echo "$SFTP_PRIVATE_KEY" > $keyfile
chmod 600 $keyfile

# copy all files to backup dir
scp -i $keyfile -P $SFTP_PORT -r $SFTP_USERNAME@$SFTP_HOST:/ $backup_dir

# compress and upload
log "Compressing..."
tar -cf - $backup_dir | xz -9 > archive.tar.xz

log "Backing up with marmalade"
marmalade backup -f archive.tar.xz
log "Backup process completed successfully!"
