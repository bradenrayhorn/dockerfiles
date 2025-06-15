#!/bin/bash

set -euo pipefail

log() {
    echo "[$(date -u '+%Y-%m-%d %H:%M:%S UTC')] $1"
}

# create working directories
working_dir="$(mktemp -d)"
cd $working_dir

backup_dir="$AWS_S3_BUCKET"
mkdir $backup_dir

# download bucket
AWS_ACCESS_KEY_ID=$AWS_S3_ACCESS_KEY_ID \
AWS_SECRET_ACCESS_KEY=$AWS_S3_ACCESS_KEY_SECRET \
AWS_DEFAULT_REGION=$AWS_S3_REGION \
aws s3 sync s3://$AWS_S3_BUCKET $backup_dir --endpoint-url "$AWS_S3_ENDPOINT" --quiet

# compress and upload
log "Compressing..."
tar -cf - $backup_dir | xz -9 > archive.tar.xz

log "Backing up with marmalade"
marmalade backup -f archive.tar.xz
log "Backup process completed successfully!"
