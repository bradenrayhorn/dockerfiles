#!/bin/bash

set -euo pipefail

log() {
    echo "[$(date -u '+%Y-%m-%d %H:%M:%S UTC')] $1"
}

# create working directories
backup_dir="$(mktemp -d)"
backup_dir_folder="archive"
mkdir $backup_dir/$backup_dir_folder
working_dir="$(mktemp -d)"

# setup auth
keyfile="$(mktemp -d)/key"
echo "$SFTP_PRIVATE_KEY" > $keyfile
chmod 600 $keyfile

mkdir -p ~/.ssh
ssh-keyscan -p $SFTP_PORT -H $SFTP_HOST >> ~/.ssh/known_hosts

# copy all files to backup folder
scp -i $keyfile -P $SFTP_PORT -r $SFTP_USERNAME@$SFTP_HOST:/ $backup_dir/$backup_dir_folder

# compress and upload
log "Compressing..."
cd $backup_dir
tar -cf - $backup_dir_folder | xz -9 > $working_dir/archive.tar.xz

log "Backing up with marmalade"
marmalade backup -f $working_dir/archive.tar.xz
log "Backup process completed successfully!"
